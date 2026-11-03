extends SceneTree
var checks=0
var failures=0
class FakeBilling extends Node:
 var acknowledged: Array=[]
 var queries=0
 var next_code=0
 func acknowledge_purchase(token): acknowledged.append(token)
 func purchase(_id,_option,_offer): return {"response_code":next_code}
 func is_ready(): return true
 func query_purchases(_type): queries+=1
 func end_connection(): pass
func check(ok: bool, label: String) -> void:
 checks+=1
 if not ok: failures+=1
 print("PASS " if ok else "FAIL ",label)
func purchase(state=1,ack=false,token="test-token") -> Dictionary:
 return {"product_ids":[CrewRelease.PRODUCT_ID],"package_name":"com.puffcrew.rapids","purchase_state":state,"is_acknowledged":ack,"purchase_token":token}
func _initialize(): call_deferred("run")
func run():
 var store=CrewStore.new()
 store.save_path="user://store-automated-qa.cfg"
 DirAccess.remove_absolute(store.save_path)
 root.add_child(store)
 var fake=FakeBilling.new();store.add_child(fake);store.client=fake
 store._updated({"response_code":0,"purchases":[purchase(2)]})
 check(not store.owned and fake.acknowledged.is_empty(),"Pending payment grants no outfit and is not acknowledged")
 store._updated({"response_code":0,"purchases":[purchase()]})
 check(not store.owned and fake.acknowledged.size()==1,"Completed purchase waits for acknowledgement")
 store._updated({"response_code":0,"purchases":[purchase()]})
 check(fake.acknowledged.size()==1,"Repeated callbacks do not duplicate in-flight acknowledgement")
 store._acknowledged({"response_code":0,"token":"unrequested"})
 check(not store.owned,"Unrequested acknowledgement cannot grant access")
 store._acknowledged({"response_code":0,"token":"test-token"})
 check(store.owned,"Successful acknowledgement unlocks bundle")
 store._updated({"response_code":1})
 check(store.owned and not store.busy,"Cancellation preserves an existing purchase")
 store._purchases({"response_code":2})
 check(store.owned,"Offline restore preserves cached access")
 store._purchases({"response_code":0,"purchases":[]})
 check(not store.owned,"Successful empty restore revokes refunded/missing access")
 store._purchases({"response_code":0,"purchases":[purchase(2)]})
 check(not store.owned and "pending" in store.status,"Pending restore remains pending and locked")
 var invalid=purchase(1,true);invalid.package_name="other.package"
 store._purchases({"response_code":0,"purchases":[invalid]})
 check(not store.owned,"Wrong package cannot unlock this game")
 invalid=purchase(1,true);invalid.product_ids=["unrelated"]
 store._updated({"response_code":0,"purchases":[invalid]})
 check(not store.owned,"Other products cannot unlock the bundle")
 invalid=purchase(1,true);invalid.is_suspended=true
 store._purchases({"response_code":0,"purchases":[invalid]})
 check(not store.owned,"Suspended entitlement is not accepted")
 store._purchases({"response_code":0,"purchases":[purchase(1,true)]})
 check(store.owned,"Acknowledged purchase restores after reinstall")
 store._set_owned(false)
 store._products({"response_code":0,"product_details":[{"product_id":CrewRelease.PRODUCT_ID,"one_time_purchase_offer_details_list":[{"formatted_price":"₹149.00","purchase_option_id":"permanent","offer_id":null}]}]})
 check(store.available and store.price=="₹149.00" and store.offer_id=="","Price and permanent offer come from store details")
 fake.next_code=1;store.buy()
 check(not store.owned and not store.busy,"Canceled launch cannot unlock outfits")
 store.restore();check(fake.queries==1,"Restore queries the user's current store purchases")
 store.shutdown();store.queue_free()
 await process_frame
 await process_frame
 DirAccess.remove_absolute("user://store-automated-qa.cfg")
 print("STORE_TESTS ",checks-failures,"/",checks," passed")
 quit(0 if failures==0 else 1)
