From: Marc Eshel <eshel@almaden.ibm.com>
Subject: NLM lock reclaim failure
Date: Wed, 11 Oct 2006 16:28:16 -0700
Message-ID: <OFE4C9C5BD.9867BFBB-ON88257204.007E2AA2-88257204.0080CB17@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXnUy-0004n6-S3
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 16:28:28 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.141])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GXnUz-0004eP-GT
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 16:28:29 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9BNSMdD023838
	for <nfs@lists.sourceforge.net>; Wed, 11 Oct 2006 19:28:22 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k9BNSLKG140304
	for <nfs@lists.sourceforge.net>; Wed, 11 Oct 2006 19:28:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k9BNSLw3028424
	for <nfs@lists.sourceforge.net>; Wed, 11 Oct 2006 19:28:21 -0400
Received: from d01ml604.pok.ibm.com (d01ml604.pok.ibm.com [9.56.227.90])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9BNSL7C028420
	for <nfs@lists.sourceforge.net>; Wed, 11 Oct 2006 19:28:21 -0400
To: "Linux NFS Mailing List" <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I see an NLM lock reclaim failure (using 2.6.17). Let me describe 
the simple case first.

1. Client gets an NLM lock
2. Server reboots
3. Client sends lock reclaim request
4. On server, nlm_open() gets return code nfserr_dropit; error gets 
   converted to nlm_lck_denied by nlm_lookup_file().
5. Client gets status=1, the lock reclaim failed

This happens _only_ when the first call to nfsd (fh_verify -> exp_find) 
comes from lockd trying to find the file. Subsequent calls seem to work.

nlm_lookup_file() -> nlm_fopen() -> nfsd_open() -> fh_verify() -> 
exp_find() returns nfserr_dropit

This problem may be related to the following commit to lockd (Trond's 
tree):
commit: 26bcbf965f857c710adafd16cf424f043006b5dd
lockd: stop abusing file_lock_list

The client earlier retained the list of outstanding locks regardless of 
reclaim return code. The change above removes all locks from the list 
and only adds them back after a successful reclaim. Since the reclaim 
fails, it is removed from the list; so the client will not try to 
reclaim the lock on a second failure.

Note that the problem is not on the client side - it seems the server 
that should drop the rpc when it gets nfserr_dropit error and not 
convert it to an nlm_lck_denied.

It get even more complicated - when the server doesn't respond 
immediately to the reclaim, client will retry the rpc, on the second 
reclaim call, the server will grant the lock to the client but since the 
client already got the nlm_lck_denied from the first call, it has 
dropped it from it list. So now we have a lock on the server for a 
client that doesn't know that it holds the lock.

Marc.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
