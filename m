Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:29155 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755832Ab3AET3W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Jan 2013 14:29:22 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Nickolai Zeldovich <nickolai@csail.mit.edu>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: avoid dereferencing null pointer in
 initiate_bulk_draining
Date: Sat, 5 Jan 2013 19:29:20 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91198F775@SACEXCMBX04-PRD.hq.netapp.com>
References: <1357413591-42579-1-git-send-email-nickolai@csail.mit.edu>
In-Reply-To: <1357413591-42579-1-git-send-email-nickolai@csail.mit.edu>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2013-01-05 at 14:19 -0500, Nickolai Zeldovich wrote:
+AD4- Fix an inverted null pointer check in initiate+AF8-bulk+AF8-draining().
+AD4- 
+AD4- Signed-off-by: Nickolai Zeldovich +ADw-nickolai+AEA-csail.mit.edu+AD4-
+AD4- ---
+AD4-  fs/nfs/callback+AF8-proc.c +AHw-    2 +--
+AD4-  1 file changed, 1 insertion(+-), 1 deletion(-)
+AD4- 
+AD4- diff --git a/fs/nfs/callback+AF8-proc.c b/fs/nfs/callback+AF8-proc.c
+AD4- index c89b26b..264d1aa 100644
+AD4- --- a/fs/nfs/callback+AF8-proc.c
+AD4- +-+-+- b/fs/nfs/callback+AF8-proc.c
+AD4- +AEAAQA- -206,7 +-206,7 +AEAAQA- static u32 initiate+AF8-bulk+AF8-draining(struct nfs+AF8-client +ACo-clp,
+AD4-  
+AD4-  		list+AF8-for+AF8-each+AF8-entry(lo, +ACY-server-+AD4-layouts, plh+AF8-layouts) +AHs-
+AD4-  			ino +AD0- igrab(lo-+AD4-plh+AF8-inode)+ADs-
+AD4- -			if (ino)
+AD4- +-			if (+ACE-ino)
+AD4-  				continue+ADs-
+AD4-  			spin+AF8-lock(+ACY-ino-+AD4-i+AF8-lock)+ADs-
+AD4-  			/+ACo- Is this layout in the process of being freed? +ACo-/

Thanks for spotting. Applied to the 'bugfixes' branch.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
