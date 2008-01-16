From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/3] Intro: Better handling coarse-grained timestamps
Date: Tue, 15 Jan 2008 21:18:32 -0500
Message-ID: <1200449912.28088.22.camel@heimdal.trondhjem.org>
References: <20080115162658.GA18911@newbie.thebellsplace.net>
	 <20080116015526.GC26010@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:50433 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754024AbYAPCSg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 21:18:36 -0500
In-Reply-To: <20080116015526.GC26010-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-15 at 20:55 -0500, Bob Bell wrote:
> On Tue, Jan 15, 2008 at 11:27:01AM -0500, Bob Bell wrote:
> >Secondly, a modification to the kernel has been made to disable the 
> >caching of negative dentries when the NFS_MOUNT_NONEGDE flag is set.  
> >Note that this does nothing to address outdated information being 
> >returned by readdir().  However, it does allow a file to be open()ed or 
> >lstat()ed if the filename is known.  Because this has a potential 
> >performance impact, it is left as an option for the user to select.
> 
> Someone pointed me to this page on NFSv4.1 directory delegations: 
> http://wiki.linux-nfs.org/wiki/index.php/NFSv4.1_Directory_Delegations
> 
> I found the following quotes intriguing:
> 
> "Even though the directories along the path are cached, [without 
> directory delegations] negative dentry caching is not allowed because it 
> potentially violates close-to-open consistency semantics."

Negative dentry caching has nothing whatsoever to do with close-to-open
semantics.

> "Close-to-open consistency currently requires that even in a case where 
> previous LOOKUPs or OPENs for a given file have recently and repeatedly 
> failed, subsequent LOOKUPs and OPENs must nevertheless be sent to the 
> server (i.e., negative caching provides no benefit in those cases)."

Nope. All close-to-open cache consistency requires is that the client
revalidate the file/directory cached data upon an open()/opendir() call
by checking the inode mtime and/or change attribute (NFSv4 only).

I think we need to revisit that wiki entry...

Trond

