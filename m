Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:64150 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837Ab3ADPvl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 10:51:41 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "ycnian@gmail.com" <ycnian@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] pnfs: Increase the refcount when LAYOUTGET fails the
 first time
Date: Fri, 4 Jan 2013 15:51:39 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91198A99A@SACEXCMBX04-PRD.hq.netapp.com>
References: <1357301989-10278-1-git-send-email-ycnian@gmail.com>
In-Reply-To: <1357301989-10278-1-git-send-email-ycnian@gmail.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-01-04 at 20:19 +-0800, ycnian+AEA-gmail.com wrote:
+AD4- From: Yanchuan Nian +ADw-ycnian+AEA-gmail.com+AD4-
+AD4- 
+AD4- The layout will be set unusable if LAYOUTGET fails. Is it reasonable to
+AD4- increase the refcount iff LAYOUTGET fails the first time?
+AD4- 
+AD4- Signed-off-by: Yanchuan Nian +ADw-ycnian+AEA-gmail.com+AD4-
+AD4- ---
+AD4-  fs/nfs/pnfs.c +AHw-    2 +--
+AD4-  1 files changed, 1 insertions(+-), 1 deletions(-)
+AD4- 
+AD4- diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
+AD4- index e7165d9..d00260b 100644
+AD4- --- a/fs/nfs/pnfs.c
+AD4- +-+-+- b/fs/nfs/pnfs.c
+AD4- +AEAAQA- -254,7 +-254,7 +AEAAQA- static void
+AD4-  pnfs+AF8-layout+AF8-set+AF8-fail+AF8-bit(struct pnfs+AF8-layout+AF8-hdr +ACo-lo, int fail+AF8-bit)
+AD4-  +AHs-
+AD4-  	lo-+AD4-plh+AF8-retry+AF8-timestamp +AD0- jiffies+ADs-
+AD4- -	if (test+AF8-and+AF8-set+AF8-bit(fail+AF8-bit, +ACY-lo-+AD4-plh+AF8-flags))
+AD4- +-	if (+ACE-test+AF8-and+AF8-set+AF8-bit(fail+AF8-bit, +ACY-lo-+AD4-plh+AF8-flags))
+AD4-  		atomic+AF8-inc(+ACY-lo-+AD4-plh+AF8-refcount)+ADs-
+AD4-  +AH0-
+AD4-  
Thank for spotting this+ACE- Applying to the bugfixes branch...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
