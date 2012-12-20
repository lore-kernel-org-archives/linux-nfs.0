Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51881 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285Ab2LTUry convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2012 15:47:54 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Orion Poplawski <orion@cora.nwra.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: umount(,MNT_DETACH) for nfsv4 hangs when using sec=krb5 and
 network is down
Date: Thu, 20 Dec 2012 20:47:52 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91196FF19@SACEXCMBX04-PRD.hq.netapp.com>
References: <loom.20121219T214634-616@post.gmane.org>
	  <4FA345DA4F4AE44899BD2B03EEEC2FA91196AE42@SACEXCMBX04-PRD.hq.netapp.com>
	  <50D236A4.6060906@cora.nwra.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91196C146@SACEXCMBX04-PRD.hq.netapp.com>
	 <50D3758D.9060808@cora.nwra.com>
In-Reply-To: <50D3758D.9060808@cora.nwra.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-12-20 at 13:31 -0700, Orion Poplawski wrote:
+AD4- On 12/19/2012 03:19 PM, Myklebust, Trond wrote:
+AD4- +AD4- 
+AD4- +AD4- Commit eb96d5c97b0825d542e9c4ba5e0a22b519355166 (SUNRPC handle
+AD4- +AD4- EKEYEXPIRED in call+AF8-refreshresult), which will be in 3.8-rc1 when Linus
+AD4- +AD4- releases it, may help.
+AD4- +AD4- 
+AD4- 
+AD4- FWIW - I cherry picked that into the latest Fedora rawhide kernel but no
+AD4- effect.  Sounds like a nice patch though, the current hang forever behavior
+AD4- doesn't seem the trigger the needed +ACI-ah, need a new ticket+ACI- response.
+AD4- 

So does simply killing the rpc.gssd process help?
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
