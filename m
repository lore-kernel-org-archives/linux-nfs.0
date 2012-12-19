Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:36075 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592Ab2LSUrW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Dec 2012 15:47:22 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1TlQY7-0002oe-7u
	for linux-nfs@vger.kernel.org; Wed, 19 Dec 2012 21:47:31 +0100
Received: from NORTHWEST-R.edge3.Denver1.Level3.net ([4.28.99.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 19 Dec 2012 21:47:31 +0100
Received: from orion by NORTHWEST-R.edge3.Denver1.Level3.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 19 Dec 2012 21:47:31 +0100
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: =?utf-8?b?dW1vdW50KCxNTlRfREVUQUNIKQ==?= for nfsv4 hangs when using sec=krb5 and network is down
Date: Wed, 19 Dec 2012 20:47:07 +0000 (UTC)
Message-ID: <loom.20121219T214634-616@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4 mounts with sec=krb5 cannot be unmounted with the network down, even with
umount -l because umount() with MNT_DETACH set will hang, presumably somewhere
in the gss stack.

A successful umount yields the following packet trace:

  1 0.000000000   10.10.20.2 -> 10.10.10.1   NFS 218 V4 Call GETATTR FH:0x3b470ee7
  2 0.000236000   10.10.10.1 -> 10.10.20.2   NFS 318 V4 Reply (Call In 1) GETATTR
  3 0.000282000   10.10.20.2 -> 10.10.10.1   TCP 66 943 > nfs [ACK] Seq=153
Ack=253 Win=331 Len=0 TSval=3468186 TSecr=878557922
  4 0.008761000   10.10.20.2 -> 10.10.10.1   TCP 66 943 > nfs [FIN, ACK] Seq=153
Ack=253 Win=331 Len=0 TSval=3468195 TSecr=878557922
  5 0.008923000   10.10.10.1 -> 10.10.20.2   TCP 66 nfs > 943 [FIN, ACK] Seq=253
Ack=154 Win=683 Len=0 TSval=878557930 TSecr=3468195
  6 0.008970000   10.10.20.2 -> 10.10.10.1   TCP 66 943 > nfs [ACK] Seq=154
Ack=254 Win=331 Len=0 TSval=3468195 TSecr=878557930

So my guess is that something in the gss stack is preventing the GETATTR call
from succeeding as unmounting succeeds without sec=krb5.  Although running
rpc.gssd and rpcidmap with -vvvv does not appear to produce any output.  A
successful unmount produces:

Dec 19 13:42:44 orca rpc.gssd[18495]: destroying client
/var/lib/nfs/rpc_pipefs/nfs/clnt27
Dec 19 13:42:44 orca rpc.gssd[18495]: destroying client
/var/lib/nfs/rpc_pipefs/nfs/clnt24

However, we need someway to be able to drop mounts after the network connection
has been removed.  This behavior is causing sever problems for our laptop and
vpn users.

Tested with:

3.6.11-3.fc18
nfs-utils-1.2.7-2.fc18

I've also filed https://bugzilla.redhat.com/show_bug.cgi?id=888942

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com

