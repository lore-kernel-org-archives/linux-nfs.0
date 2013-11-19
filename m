Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36305 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752102Ab3KSWrN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Nov 2013 17:47:13 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 3 1/1] NFSv4 wait on recovery for async session
 errors
Date: Tue, 19 Nov 2013 22:47:12 +0000
Message-ID: <1384901232.45997.4.camel@leira.trondhjem.org>
References: <1384551376-8734-1-git-send-email-andros@netapp.com>
	 <1384897797.45997.1.camel@leira.trondhjem.org>
	 <1384900469.45997.2.camel@leira.trondhjem.org>
	 <C662575C-1FBD-4E72-B569-0BD4FC6BFE47@netapp.com>
In-Reply-To: <C662575C-1FBD-4E72-B569-0BD4FC6BFE47@netapp.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-11-19 at 22:43 +-0000, Adamson, Andy wrote:
+AD4- Why not recover the lease? Shouldn't NFS4ERR+AF8-EXPIRED be left for the async handler?

No, because then it will retry the operation. Since it is impossible to
recover the delegation at this point, then that will result in another
failure.

+AD4- --+AD4-Andy
+AD4- 
+AD4- On Nov 19, 2013, at 5:34 PM, +ACI-Myklebust, Trond+ACI- +ADw-Trond.Myklebust+AEA-netapp.com+AD4-
+AD4-  wrote:
+AD4- 
+AD4- +AD4- On Tue, 2013-11-19 at 16:49 -0500, Trond Myklebust wrote:
+AD4- +AD4APg- There is a second patch that goes with this problem. Please see the
+AD4- +AD4APg- following attachment.
+AD4- +AD4- 
+AD4- +AD4- V2: Don't return an error when we know that the stateid is no longer
+AD4- +AD4- valid.
+AD4- +AD4- 
+AD4- +AD4- -- 
+AD4- +AD4- Trond Myklebust
+AD4- +AD4- Linux NFS client maintainer
+AD4- +AD4- 
+AD4- +AD4- NetApp
+AD4- +AD4- Trond.Myklebust+AEA-netapp.com
+AD4- +AD4- www.netapp.com
+AD4- +AD4- +ADw-0001-NFSv4-Update-list-of-irrecoverable-errors-on-DELEGRE.patch+AD4-
+AD4- 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
