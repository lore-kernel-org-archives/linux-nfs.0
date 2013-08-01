Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ecs-ex10-cas2.engr.uconn.edu ([137.99.15.237]:18648 "EHLO
	mail.engr.uconn.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757219Ab3HAUvw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Aug 2013 16:51:52 -0400
Message-ID: <51FAC933.40508@engr.uconn.edu>
Date: Thu, 1 Aug 2013 16:46:43 -0400
From: Rohit Kumar Mehta <rohitm@engr.uconn.edu>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>
Subject: Trouble with kerberized NFS client after upgrading from nfs-utils
 1.2.0 to 1.2.5
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello everyone, I am stuck trying to figure out why I cannot get 
sec=krb5 Linux clients working after upgrading from Ubuntu 10.04 LTS 
(Lucid) to 12.04 (Precise)

I suspect the same problem is with the newer nfs-utils, but cannot be sure.

On the old (working) Lucid system, I think the important software is:
# dpkg -l |grep nfs-common
ii  nfs-common 1:1.2.0-4ubuntu4.2                              NFS 
support files common to client and serve
# uname -a
Linux cselin3 2.6.32-29-generic #58-Ubuntu SMP Fri Feb 11 20:52:10 UTC 
2011 x86_64 GNU/Linux

And on the newer (sec=krb5 mounts fail) system, the important software is:
# dpkg -l |grep nfs-common
ii  nfs-common 1:1.2.5-3ubuntu3.1                      NFS support files 
common to client and server
# uname -a
Linux c27-00 3.2.0-51-generic #77-Ubuntu SMP Wed Jul 24 20:18:19 UTC 
2013 x86_64 x86_64 x86_64 GNU/Linux


The NFS server we are using is a Hitachi BlueARC, and like I said, older 
Linux clients work fine.  After upgrading to new kernel and

nfs-utils, any attempt to mount yields an error:
# mount hnas.engr.uconn.edu:/EngrUser/users/rohitm /foo -o sec=krb5
mount.nfs: access denied by server while mounting 
hnas.engr.uconn.edu:/EngrUser/users/rohitm

I've reproduced the same behavior with both -t nfs4 and -t nfs. (Both 
nfsv3 and nfsv4 work with kerberos security in our configuration with 
Lucid, but not Precise)  I've checked the Kerberos credential cache:

root@c27-00:~# klist -e -f -c /tmp/krb5cc_machine_ENGR.UCONN.EDU
Ticket cache: FILE:/tmp/krb5cc_machine_ENGR.UCONN.EDU
Default principal: nfs/c27-00.engr.uconn.edu@ENGR.UCONN.EDU

Valid starting    Expires           Service principal
01/08/2013 15:40  02/08/2013 01:40 krbtgt/ENGR.UCONN.EDU@ENGR.UCONN.EDU
     renew until 02/08/2013 15:40, Flags: FRI
     Etype (skey, tkt): des3-cbc-sha1, des3-cbc-sha1
01/08/2013 15:40  02/08/2013 01:40 nfs/hnas.engr.uconn.edu@ENGR.UCONN.EDU
     renew until 02/08/2013 15:40, Flags: FRT
     Etype (skey, tkt): des3-cbc-sha1, des3-cbc-sha1

I also have rpc.idmapd and rpc.gssd running with extra verbosity.  I 
don't see anything blatantly wrong.  This looks slightly suspicious:
Aug  1 16:32:50 c27-00 rpc.gssd[780]: creating tcp client for server 
hnas.engr.uconn.edu
Aug  1 16:32:50 c27-00 rpc.gssd[780]: DEBUG: port already set to 2049
Aug  1 16:32:50 c27-00 rpc.gssd[780]: creating context with server 
nfs@hnas.engr.uconn.edu
Aug  1 16:32:50 c27-00 rpc.gssd[780]: WARNING: Failed to create krb5 
context for user with uid 0 for server hnas.engr.uconn.edu
Aug  1 16:32:50 c27-00 rpc.gssd[780]: WARNING: Failed to create machine 
krb5 context with credentials cache 
FILE:/tmp/krb5cc_machine_ENGR.UCONN.EDU for server hnas.engr.uconn.edu
Aug  1 16:32:50 c27-00 rpc.gssd[780]: WARNING: Failed to create machine 
krb5 context with any credentials cache for server hnas.engr.uconn.edu
Aug  1 16:32:50 c27-00 rpc.gssd[780]: doing error downcall
Aug  1 16:32:50 c27-00 rpc.gssd[780]: dir_notify_handler: sig 37 si 
0x7fffdf0135b0 data 0x7fffdf013480
Aug  1 16:32:50 c27-00 rpc.gssd[780]: dir_notify_handler: sig 37 si 
0x7fffdf0135b0 data 0x7fffdf013480
Aug  1 16:32:50 c27-00 rpc.gssd[780]: dir_notify_handler: sig 37 si 
0x7fffdf0134f0 data 0x7fffdf0133c0
Aug  1 16:32:50  rpc.gssd[780]: last message repeated 4 times
Aug  1 16:32:50 c27-00 rpc.gssd[780]: destroying client 
/run/rpc_pipefs/nfs/clnt5
Aug  1 16:32:50 c27-00 rpc.gssd[780]: destroying client 
/run/rpc_pipefs/nfs/clnt4

I am able to successfuly get the nfs principal for the client from 
/etc/krb5.keytab "nfs/c27-00.engr.uconn.edu" and I can see the principal 
for the server "nfs/hnas.engr.uconn.edu" in cache 
/tmp/krb5cc_machine_ENGR.UCONN.EDU.

I appreciate any advice or assistance.  Thanks in advance!
Rohit

-- 
Rohit Mehta
Computer Engineer
University of Connecticut
Engineering Computing Services
371 Fairfield Road Unit 4031
Storrs, CT 06269-4031

Office: (860) 486 - 2331
Fax: (860) 486 - 1273

