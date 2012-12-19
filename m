Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:55666 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983Ab2LSWT4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2012 17:19:56 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Orion Poplawski <orion@cora.nwra.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: umount(,MNT_DETACH) for nfsv4 hangs when using sec=krb5 and
 network is down
Date: Wed, 19 Dec 2012 22:19:54 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91196C146@SACEXCMBX04-PRD.hq.netapp.com>
References: <loom.20121219T214634-616@post.gmane.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91196AE42@SACEXCMBX04-PRD.hq.netapp.com>
	 <50D236A4.6060906@cora.nwra.com>
In-Reply-To: <50D236A4.6060906@cora.nwra.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-12-19 at 14:50 -0700, Orion Poplawski wrote:
+AD4- On 12/19/2012 02:08 PM, Myklebust, Trond wrote:
+AD4- +AD4- On Wed, 2012-12-19 at 20:47 +000-, Orion Poplawski wrote:
+AD4- +AD4APg-
+AD4- +AD4APg- However, we need someway to be able to drop mounts after the network connection
+AD4- +AD4APg- has been removed.  This behavior is causing sever problems for our laptop and
+AD4- +AD4APg- vpn users.
+AD4- +AD4APg-
+AD4- +AD4APg- Tested with:
+AD4- +AD4APg-
+AD4- +AD4APg- 3.6.11-3.fc18
+AD4- +AD4APg- nfs-utils-1.2.7-2.fc18
+AD4- +AD4APg-
+AD4- +AD4APg- I've also filed https://bugzilla.redhat.com/show+AF8-bug.cgi?id+AD0-888942
+AD4- +AD4- 
+AD4- +AD4- No. What you need is a way to unmount +AF8-before+AF8- you kill the network.
+AD4- +AD4- Once the network is gone, you are in severe data loss territory, and you
+AD4- +AD4- are entirely on your own dealing with that problem...
+AD4- +AD4- 
+AD4- +AD4- Maybe one day we will get round to supporting offline mounts, but that's
+AD4- +AD4- not the case today.
+AD4- +AD4- 
+AD4- 
+AD4- I agree (see https://bugzilla.gnome.org/show+AF8-bug.cgi?id+AD0-387832 for example),
+AD4- however it happens (and, because of lack of support as indicated by the bug,
+AD4- hard to prevent) and it seems unfortunate to then subject the user to hanging
+AD4- mounts (which will effectively lock up the desktop).  It currently is possible
+AD4- for sec+AD0-sys mounts, so I thought it would be worth while making it work for
+AD4- sec+AD0-krb5 mounts.  The same data loss issues are present for both.

Any application which is already hanging on a file in that filesystem
will continue to hang across a 'umount -l'. The only thing you are doing
is preventing future attempts to access the filesystem.

As I said above, this whole thing really needs to be handled as part of
the suspend scripts and/or networkmanager...

+AD4- We have put work in the past into making umount work for offline nfs mounts
+AD4- (https://bugzilla.redhat.com/show+AF8-bug.cgi?id+AD0-820707).  In fact that looks
+AD4- remarkably familiar :).
+AD4- 
+AD4- +AFs-  131.832005+AF0- umount.nfs4     D f1585bc8     0  1959   1958 0x00000080
+AD4- +AFs-  131.832005+AF0-  f1585c34 00000086 0000ea8a f1585bc8 c045a297 f705f110 644b6440
+AD4- 0000001c
+AD4- +AFs-  131.832005+AF0-  f1585bd8 c0cd5080 c0cd5080 00000282 f1585c00 f7591080 f3a27110
+AD4- f1585c24
+AD4- +AFs-  131.832005+AF0-  00000000 c0d2e280 00000282 00000246 f1585c00 c097a273 f1585c2c
+AD4- f7ee11c5
+AD4- +AFs-  131.832005+AF0- Call Trace:
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c045a297+AD4AXQ- ? +AF8AXw-internal+AF8-add+AF8-timer+0x77/0xc-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c097a273+AD4AXQ- ? +AF8-raw+AF8-spin+AF8-unlock+AF8-bh+0x13/0x2-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7ee11c5+AD4AXQ- ? rpc+AF8-wake+AF8-up+AF8-first+0x65/0x1- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7eda240+AD4AXQ- ? rpc+AF8-show+AF8-tasks+0x1b0/0x1b0- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c09794d3+AD4AXQ- schedule+0x23/0x6-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7ee064d+AD4AXQ- rpc+AF8-wait+AF8-bit+AF8-killable+0x2d/0x7- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c0977fc1+AD4AXQ- +AF8AXw-wait+AF8-on+AF8-bit+0x51/0x7-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7ee0620+AD4AXQ- ? +AF8AXw-rpc+AF8-wait+AF8-for+AF8-completion+AF8-task+0x30/0x3- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7ee0620+AD4AXQ- ? +AF8AXw-rpc+AF8-wait+AF8-for+AF8-completion+AF8-task+0x30/0x3- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c0978041+AD4AXQ- out+AF8-of+AF8-line+AF8-wait+AF8-on+AF8-bit+0x61/0x7-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c046c100+AD4AXQ- ? autoremove+AF8-wake+AF8-function+0x50/0x5-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7ee198f+AD4AXQ- +AF8AXw-rpc+AF8-execute+0x11f/0x//0- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c0507774+AD4AXQ- ? mempool+AF8-alloc+0x44/0x1-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7ed8a50+AD4AXQ- ? call+AF8-connect+0x90/0x9- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7ed8a50+AD4AXQ- ? call+AF8-connect+0x90/0x9- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c046c0a3+AD4AXQ- ? wake+AF8-up+AF8-bit+0x23/0x3-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7ee1ec8+AD4AXQ- rpc+AF8-execute+0x48/0x8- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7ed9929+AD4AXQ- rpc+AF8-run+AF8-task+0x59/0x7- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f7ed9a3c+AD4AXQ- rpc+AF8-call+AF8-sync+0x3//Ux6- +AFs-sunrpc+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f8a402fc+AD4AXQ- +AF8-nfs4+AF8-call+AF8-sync+0x3//Ux5- +AFs-nfsv4+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f8a403d5+AD4AXQ- +AF8-nfs4+AF8-proc+AF8-getattr+0x95/0xa- +AFs-nfsv4+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f8a41bab+AD4AXQ- nfs4+AF8-proc+AF8-getattr+0x3//Ux6- +AFs-nfsv4+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f897f891+AD4AXQ- +AF8AXw-nfs+AF8-revalidate+AF8-inode+0x81/0x2- +AFs-nfs+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f897fbd2+AD4AXQ- nfs+AF8-revalidate+AF8-inode+0x62/0x9- +AFs-nfs+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f89793ef+AD4AXQ- nfs+AF8-check+AF8-verifier+0x4f/0x8- +AFs-nfs+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f897b4da+AD4AXQ- nfs+AF8-lookup+AF8-revalidate+0x2ba/0x440- +AFs-nfs+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c055f8cb+AD4AXQ- ? follow+AF8-managed+0x19b/0x//0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c0560000+AD4AXQ- ? unlazy+AF8-walk+0xf0/0x1-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-f897c184+AD4AXQ- nfs4+AF8-lookup+AF8-revalidate+0x34/0xe- +AFs-nfs+AF0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c055fedc+AD4AXQ- complete+AF8-walk+0x8c/0xc-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c05611b3+AD4AXQ- path+AF8-lookupat+0x63/0x6-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c05617ca+AD4AXQ- do+AF8-path+AF8-lookup+0x2a/0xb-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c0563df6+AD4AXQ- user+AF8-path+AF8-at+AF8-empty+0x46/0x8-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c097d440+AD4AXQ- ? vmalloc+AF8-fault+0x176/0x174-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c097d5f7+AD4AXQ- ? do+AF8-page+AF8-fault+0x1b7/0x450-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c0563e4f+AD4AXQ- user+AF8-path+AF8-at+0x1f/0x3-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c05707b1+AD4AXQ- sys+AF8-umount+0x41/0x3-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c04bd59c+AD4AXQ- ? +AF8AXw-audit+AF8-syscall+AF8-entry+0xb//Ux2-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c04bdac6+AD4AXQ- ? +AF8AXw-audit+AF8-syscall+AF8-exit+0x356/0x//0-
+AD4- +AFs-  131.832005+AF0-  +AFsAPA-c0980fdf+AD4AXQ- sysenter+AF8-do+AF8-call+0x12/0x2-
+AD4- 
+AD4- I wonder if it never did get fixed for krb5 mounts then...

Commit eb96d5c97b0825d542e9c4ba5e0a22b519355166 (SUNRPC handle
EKEYEXPIRED in call+AF8-refreshresult), which will be in 3.8-rc1 when Linus
releases it, may help.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
