Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:28509 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974Ab2LSVJC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2012 16:09:02 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Orion Poplawski <orion@cora.nwra.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: umount(,MNT_DETACH) for nfsv4 hangs when using sec=krb5 and
 network is down
Date: Wed, 19 Dec 2012 21:08:59 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91196AE42@SACEXCMBX04-PRD.hq.netapp.com>
References: <loom.20121219T214634-616@post.gmane.org>
In-Reply-To: <loom.20121219T214634-616@post.gmane.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-12-19 at 20:47 +-0000, Orion Poplawski wrote:
+AD4- nfs4 mounts with sec+AD0-krb5 cannot be unmounted with the network down, even with
+AD4- umount -l because umount() with MNT+AF8-DETACH set will hang, presumably somewhere
+AD4- in the gss stack.
+AD4- 
+AD4- A successful umount yields the following packet trace:
+AD4- 
+AD4-   1 0.000000000   10.10.20.2 -+AD4- 10.10.10.1   NFS 218 V4 Call GETATTR FH:0x3b470ee7
+AD4-   2 0.000236000   10.10.10.1 -+AD4- 10.10.20.2   NFS 318 V4 Reply (Call In 1) GETATTR
+AD4-   3 0.000282000   10.10.20.2 -+AD4- 10.10.10.1   TCP 66 943 +AD4- nfs +AFs-ACK+AF0- Seq+AD0-153
+AD4- Ack+AD0-253 Win+AD0-331 Len+AD0-0 TSval+AD0-3468186 TSecr+AD0-878557922
+AD4-   4 0.008761000   10.10.20.2 -+AD4- 10.10.10.1   TCP 66 943 +AD4- nfs +AFs-FIN, ACK+AF0- Seq+AD0-153
+AD4- Ack+AD0-253 Win+AD0-331 Len+AD0-0 TSval+AD0-3468195 TSecr+AD0-878557922
+AD4-   5 0.008923000   10.10.10.1 -+AD4- 10.10.20.2   TCP 66 nfs +AD4- 943 +AFs-FIN, ACK+AF0- Seq+AD0-253
+AD4- Ack+AD0-154 Win+AD0-683 Len+AD0-0 TSval+AD0-878557930 TSecr+AD0-3468195
+AD4-   6 0.008970000   10.10.20.2 -+AD4- 10.10.10.1   TCP 66 943 +AD4- nfs +AFs-ACK+AF0- Seq+AD0-154
+AD4- Ack+AD0-254 Win+AD0-331 Len+AD0-0 TSval+AD0-3468195 TSecr+AD0-878557930
+AD4- 
+AD4- So my guess is that something in the gss stack is preventing the GETATTR call
+AD4- from succeeding as unmounting succeeds without sec+AD0-krb5.  Although running
+AD4- rpc.gssd and rpcidmap with -vvvv does not appear to produce any output.  A
+AD4- successful unmount produces:
+AD4- 
+AD4- Dec 19 13:42:44 orca rpc.gssd+AFs-18495+AF0-: destroying client
+AD4- /var/lib/nfs/rpc+AF8-pipefs/nfs/clnt27
+AD4- Dec 19 13:42:44 orca rpc.gssd+AFs-18495+AF0-: destroying client
+AD4- /var/lib/nfs/rpc+AF8-pipefs/nfs/clnt24
+AD4- 
+AD4- However, we need someway to be able to drop mounts after the network connection
+AD4- has been removed.  This behavior is causing sever problems for our laptop and
+AD4- vpn users.
+AD4- 
+AD4- Tested with:
+AD4- 
+AD4- 3.6.11-3.fc18
+AD4- nfs-utils-1.2.7-2.fc18
+AD4- 
+AD4- I've also filed https://bugzilla.redhat.com/show+AF8-bug.cgi?id+AD0-888942

No. What you need is a way to unmount +AF8-before+AF8- you kill the network.
Once the network is gone, you are in severe data loss territory, and you
are entirely on your own dealing with that problem...

Maybe one day we will get round to supporting offline mounts, but that's
not the case today.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
