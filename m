From: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 0/3] Intro: Better handling coarse-grained timestamps
Date: Tue, 15 Jan 2008 20:55:27 -0500
Message-ID: <20080116015526.GC26010@newbie.thebellsplace.net>
References: <20080115162658.GA18911@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv03.macroped.com ([74.52.9.226]:53660 "EHLO
	srv03.macroped.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbYAPBzb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 20:55:31 -0500
Received: from newbie (c-75-67-251-249.hsd1.nh.comcast.net [75.67.251.249])
	(authenticated bits=0)
	by srv03.macroped.com (8.13.8/8.13.8) with ESMTP id m0G1vLig009254
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jan 2008 20:57:22 -0500
In-Reply-To: <20080115162658.GA18911-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 15, 2008 at 11:27:01AM -0500, Bob Bell wrote:
>Secondly, a modification to the kernel has been made to disable the 
>caching of negative dentries when the NFS_MOUNT_NONEGDE flag is set.  
>Note that this does nothing to address outdated information being 
>returned by readdir().  However, it does allow a file to be open()ed or 
>lstat()ed if the filename is known.  Because this has a potential 
>performance impact, it is left as an option for the user to select.

Someone pointed me to this page on NFSv4.1 directory delegations: 
http://wiki.linux-nfs.org/wiki/index.php/NFSv4.1_Directory_Delegations

I found the following quotes intriguing:

"Even though the directories along the path are cached, [without 
directory delegations] negative dentry caching is not allowed because it 
potentially violates close-to-open consistency semantics."

"Close-to-open consistency currently requires that even in a case where 
previous LOOKUPs or OPENs for a given file have recently and repeatedly 
failed, subsequent LOOKUPs and OPENs must nevertheless be sent to the 
server (i.e., negative caching provides no benefit in those cases)."

I admittedly know little about what is being discussed here.  However, 
is it possible that the Linux NFS client should *NEVER* cache negative 
entries?  (well, maybe with the exception of "nocto")

I'm interested if anyone has thoughts on the matter, though I know don't 
enough to argue either side, so here's a really easy chance to win an 
argument. :)

-- 
Bob Bell
