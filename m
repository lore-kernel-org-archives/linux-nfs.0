Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.ist.utl.pt ([193.136.128.21]:41320 "EHLO smtp1.ist.utl.pt"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932268Ab0I3Rlq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 13:41:46 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by smtp1.ist.utl.pt (Postfix) with ESMTP id 5DE2A70003F8
	for <linux-nfs@vger.kernel.org>; Thu, 30 Sep 2010 18:31:41 +0100 (WEST)
Received: from smtp1.ist.utl.pt ([127.0.0.1])
	by localhost (smtp1.ist.utl.pt [127.0.0.1]) (amavisd-new, port 10025)
	with LMTP id 13g6Xx6kiBJz for <linux-nfs@vger.kernel.org>;
	Thu, 30 Sep 2010 18:31:40 +0100 (WEST)
Received: from mail2.ist.utl.pt (mail2.ist.utl.pt [IPv6:2001:690:2100:1::c])
	by smtp1.ist.utl.pt (Postfix) with ESMTP id AE7C770003D2
	for <linux-nfs@vger.kernel.org>; Thu, 30 Sep 2010 18:31:40 +0100 (WEST)
Received: from coyote.ist.utl.pt (unknown [IPv6:2001:690:2100:2:21d:92ff:fea9:c53d])
	(Authenticated sender: ist146506)
	by mail2.ist.utl.pt (Postfix) with ESMTPSA id B1D952008D52
	for <linux-nfs@vger.kernel.org>; Thu, 30 Sep 2010 18:31:40 +0100 (WEST)
Date: Thu, 30 Sep 2010 18:31:40 +0100
From: =?UTF-8?B?Q2zDoXVkaW8=?= Martins <ctpm@ist.utl.pt>
To: linux-nfs@vger.kernel.org
Subject: rpc.gssd / kernel infinite loop when a kerberos ticket expires
Message-Id: <20100930183140.ff044a4e.ctpm@ist.utl.pt>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


 Greetings,

 During linux NFS4 server and client testing, I think I have found a
bug which causes an infinite loop on a client machine. I am not sure if
this should be considered a kernel or a gssd specific bug (or both).

 Steps to reproduce:

 NFS4 server running kernel 2.6.36-rc5-00073-g57aebd7 (from linus'
git), with an export configured for krb5p security. The client is
running 2.6.36-rc6-00006-g4193d91 (a bit newer than the server).
nfs-utils is version 1.2.3:

(server)
#exportfs -v
/srv/ts2        193.136.0.0/16(rw,wdelay,root_squash,no_subtree_check,fsid=0,sec=krb5p,rw,root_squash,no_all_squash)

Both client and server have keytabs including encryption type aes256-cts:

(client)
# klist -ek /etc/krb5.keytab
Keytab name: WRFILE:/etc/krb5.keytab
KVNO Principal
---- --------------------------------------------------------------------------
   4 nfs/stor-test2.ciist.ist.utl.pt@IST.UTL.PT (AES-256 CTS mode with 96-bit SHA-1 HMAC)

(server)
## klist -ek /etc/krb5.keytab
Keytab name: WRFILE:/etc/krb5.keytab
KVNO Principal
---- --------------------------------------------------------------------------
   6 nfs/stor-test.ciist.ist.utl.pt@IST.UTL.PT (AES-256 CTS mode with 96-bit SHA-1 HMAC)
   6 nfs/stor-test.ciist.ist.utl.pt@IST.UTL.PT (Triple DES cbc mode with HMAC/sha1)


On the client, the remote filesystem is mounted with:

# mount -t nfs4 stor-test.ciist.ist.utl.pt:/ /mnt -o sec=krb5p

 So we should be making use of the gss AES encryption support recently
commited to the kernel and nfs-utils.

 Now after mounting, everything looks reasonable both on the client and
server. I can su to different local usernames on the client, and use
kinit to obtain tickets for several valid principal (the server knows
all those principals), and do regular read/write file operations.

 Up to this point, so far so good. Now let it sit idle for a few hours -
enough to expire the user tickets:

(client)
#klist
Ticket cache: FILE:/tmp/krb5cc_33
Default principal: ist90001@IST.UTL.PT

Valid starting     Expires            Service principal
09/30/10 04:24:28  09/30/10 14:24:28  krbtgt/IST.UTL.PT@IST.UTL.PT
        renew until 10/01/10 04:24:24
09/30/10 04:25:21  09/30/10 14:24:28  nfs/stor-test.ciist.ist.utl.pt@IST.UTL.PT
        renew until 10/01/10 04:24:24

 So this ticket expired at 14:24:28, but now it's about 15:37, and I do
an ls on a remote directory where this principal has "rwxcty" perms
(one that definitely worked a few hours ago). This results in a stuck
"ls" command (SIGKILL doesn't work) and rpc.gssd is using up ~99% CPU
time. I had rpc.gssd started with -vvvv, and this is what I get:

Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt23)
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: handle_gssd_upcall: 'mech=krb5 uid=146506 enctypes=18,17,16,23,3,1,2 '
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt23)
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: process_krb5_upcall: service is '<null>'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: getting credentials for client with uid 146506 for server stor-test.ciist.ist.utl.pt
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_machine_IST.UTL.PT' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_machine_IST.UTL.PT' owned by 0, not 146506
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_146506' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_146506' is expired or corrupt
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_90001' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_90001' owned by 90001, not 146506
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_33' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_33' owned by 33, not 146506
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_8500' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_8500' owned by 8500, not 146506
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: WARNING: Failed to create krb5 context for user with uid 146506 for server stor-test.ciist.ist.utl.pt
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: doing error downcall
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt23)
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: handle_gssd_upcall: 'mech=krb5 uid=33 enctypes=18,17,16,23,3,1,2 '
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt23)
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: process_krb5_upcall: service is '<null>'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: getting credentials for client with uid 33 for server stor-test.ciist.ist.utl.pt
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_machine_IST.UTL.PT' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_machine_IST.UTL.PT' owned by 0, not 33
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_146506' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_146506' owned by 146506, not 33
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_90001' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_90001' owned by 90001, not 33
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_33' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_33' is expired or corrupt
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_8500' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_8500' owned by 8500, not 33
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: WARNING: Failed to create krb5 context for user with uid 33 for server stor-test.ciist.ist.utl.pt
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: doing error downcall
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt23)
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: handle_gssd_upcall: 'mech=krb5 uid=146506 enctypes=18,17,16,23,3,1,2 '
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt23)
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: process_krb5_upcall: service is '<null>'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: getting credentials for client with uid 146506 for server stor-test.ciist.ist.utl.pt
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_machine_IST.UTL.PT' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_machine_IST.UTL.PT' owned by 0, not 146506
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_146506' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_146506' is expired or corrupt
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_90001' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_90001' owned by 90001, not 146506
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_33' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_33' owned by 33, not 146506
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_8500' being considered, with preferred realm 'IST.UTL.PT'
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: CC file '/tmp/krb5cc_8500' owned by 8500, not 146506
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: WARNING: Failed to create krb5 context for user with uid 146506 for server stor-test.ciist.ist.utl.pt
Sep 30 15:37:42 stor-test2 rpc.gssd[2927]: doing error downcall


...and so on. The machine gets quite unresponsive and I have to reboot
to get rid of the hung processes.

 On the log transcribed above, note that gssd seems to be iterating
over all the cred. cache files on /tmp. The "ls" is being exec'ed as
uid=33, so IMO it should be looking at /tmp/krb5cc_33, deciding that
the creds have expired, and return an error, and the kernel client
should return an error to the "ls" process.
 Instead, what we're seeing is the above downcall/upcall infinite loop,
which seems to hint that the kernel client is not rate-limiting any
kind of requests to gssd, and does not seem to do anything about the
error downcalls from gssd.

 I couldn't get any interesting client kernel messages to corelate to
the gssd log (apart from OOM being invoked after a while to kill
rsyslogd which got overwhelmed by gssd debug info).

 While this was happening, I verified that the client does not get to
the point of establishing a new connection to the server, so this would
seem to be a client related problem.

 Please let me know if you would like me to provide further information
about this test setup or if you need any trace info. I will also gladly
run any further diagnostics you may like to debug this.

 Thanks in advance for any help with this.

Best regards

Cláudio

