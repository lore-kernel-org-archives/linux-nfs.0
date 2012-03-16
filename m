Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965332Ab2CPPqp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Mar 2012 11:46:45 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2GFkj2F026014
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 11:46:45 -0400
Received: from [10.36.5.85] (vpn1-5-85.ams2.redhat.com [10.36.5.85])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q2GFkhOw024646
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 11:46:44 -0400
Message-ID: <1331912791.2336.3.camel@localhost>
Subject: Error: state manager encountered RPCSEC_GSS session expired against
 NFSv4 server
From: Sachin Prabhu <sprabhu@redhat.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 16 Mar 2012 15:46:31 +0000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have a user report that they see the following messages
in /var/log/messages and the NFS share hangs when a user's kerberos
credentials expire.

kernel: Error: state manager encountered RPCSEC_GSS session expired
against NFSv4 server vm140-31.

The reproducer is as follows

1. Configure NFS4 + Kerberos, mount nfs4 share on the client side using
sec=krb5.

2. Create 2 nfsusers, login as user1, obtain a kerberos ticket with a
short duration and open a file on the nfs share. Leave this file open
# su - user1
$ kinit -l 5m
$ cd /home/user1
$ touch file1.txt
$ sleep 100000 < file1.txt &

3. After 300 seconds, on a different terminal, login as user2, obtain a
kerberos ticket and attempt to open a file.
# su - user2
$ kinit
$ cd /home/user2
$ touch myfile1.txt
.
.
At this point, the process hangs and /var/log/messages are filled up
with the following messages.
kernel: Error: state manager encountered RPCSEC_GSS session expired
against NFSv4 server $(hostname)

On further debugging, we found the cause to be the that the state
manager uses the credentials of the first stateowner with open files it
finds. These are returned by nfs4_get_renew_cred_locked() ->
nfs4_get_renew_cred_server_locked() to call the RENEW.

1) The server before it opens a file needs to set a client id. It does
this by calling the SET_CLIENTID call. The server in response returns a
client id. 
Since kernel 2.6.29(commit a7b721037f898b29a8083da59b1dccd3da385b07) the
SET_CLIENTID call is made using the machine credentials. 

2) However all subsequent RENEW calls for that clientid, the server uses
the first credential it finds which is used by an open file on that
machine.  In our test case, it is the user with the expired ticket. 
When the ticket expires, the call to refresh the credentials, made at
call_refresh -> rpcauth_refreshcred -> gss_refresh()
returns EKEYEXPIRED.
This means that the RENEW call fails before it could be sent over the
wire. 
The clientid on the server eventually expires.

3) When the user with the valid ticket then attempts to open a file, the
server returns a NFS4ERR_EXPIRED which indicates that clientid at the
server is no longer valid. A warning message is printed out at this
time. To fix this, the client attempts to RENEW. This hits the problem
in step 2.

Step 2 and 3 now run continously and no RENEW calls are sent over the
wire.

The SET_CLIENTID calls are made using the machine creds. Why don't we
simply use the machine creds to renew the clientid?

Something similar to the patch below should do the trick.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ec9f6ef..607ba50 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6194,7 +6194,7 @@ struct nfs4_state_recovery_ops
nfs41_nograce_recovery_ops = {
 
 struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
        .sched_state_renewal = nfs4_proc_async_renew,
-       .get_state_renewal_cred_locked = nfs4_get_renew_cred_locked,
+       .get_state_renewal_cred_locked = nfs4_get_setclientid_cred,
        .renew_lease = nfs4_proc_renew,
 };


Sachin Prabhu

