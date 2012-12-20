Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5275 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567Ab2LTWB5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2012 17:01:57 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Orion Poplawski <orion@cora.nwra.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: umount(,MNT_DETACH) for nfsv4 hangs when using sec=krb5 and
 network is down
Date: Thu, 20 Dec 2012 22:01:54 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911970163@SACEXCMBX04-PRD.hq.netapp.com>
References: <loom.20121219T214634-616@post.gmane.org>
	   <4FA345DA4F4AE44899BD2B03EEEC2FA91196AE42@SACEXCMBX04-PRD.hq.netapp.com>
	   <50D236A4.6060906@cora.nwra.com>
	  <4FA345DA4F4AE44899BD2B03EEEC2FA91196C146@SACEXCMBX04-PRD.hq.netapp.com>
	  <50D3758D.9060808@cora.nwra.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91196FF19@SACEXCMBX04-PRD.hq.netapp.com>
	 <50D388A9.9060300@cora.nwra.com>
In-Reply-To: <50D388A9.9060300@cora.nwra.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-12-20 at 14:52 -0700, Orion Poplawski wrote:
+AD4- On 12/20/2012 01:47 PM, Myklebust, Trond wrote:
+AD4- +AD4- On Thu, 2012-12-20 at 13:31 -0700, Orion Poplawski wrote:
+AD4- +AD4APg- On 12/19/2012 03:19 PM, Myklebust, Trond wrote:
+AD4- +AD4APgA+-
+AD4- +AD4APgA+- Commit eb96d5c97b0825d542e9c4ba5e0a22b519355166 (SUNRPC handle
+AD4- +AD4APgA+- EKEYEXPIRED in call+AF8-refreshresult), which will be in 3.8-rc1 when Linus
+AD4- +AD4APgA+- releases it, may help.
+AD4- +AD4APgA+-
+AD4- +AD4APg-
+AD4- +AD4APg- FWIW - I cherry picked that into the latest Fedora rawhide kernel but no
+AD4- +AD4APg- effect.  Sounds like a nice patch though, the current hang forever behavior
+AD4- +AD4APg- doesn't seem the trigger the needed +ACI-ah, need a new ticket+ACI- response.
+AD4- +AD4APg-
+AD4- +AD4- 
+AD4- +AD4- So does simply killing the rpc.gssd process help?
+AD4- +AD4- 
+AD4- 
+AD4- Yes, if automount is already stopped (these are automounted directories).  If
+AD4- automount is running, it still seems to hang.  I think I'm going to need to
+AD4- spend some time talking to Ian.
+AD4- 

I'd suggest also taking a long hard look at rpc.gssd and making sure
that it handles ENETUNREACH, ECONNREFUSED and friends correctly. I
suspect right now it is just baling out of the upcall instead of
completing it by propagating the error reply to the kernel.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
