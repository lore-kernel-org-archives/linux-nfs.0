Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32678 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756568Ab1H3UeO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2011 16:34:14 -0400
Subject: Re: [PATCH] NFSD: Add a cache for fs_locations information
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Tue, 30 Aug 2011 16:34:11 -0400
In-Reply-To: <4E5D46EB.7030102@panasas.com>
References: <20110829185115.3413.92459.stgit@matisse.1015granger.net>
	 <20110830151845.4dec5b40@tlielax.poochiereds.net>
	 <852F14A9-7826-47A0-BCD6-D5D46E38A39C@oracle.com>
	 <4E5D46EB.7030102@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1314736451.10572.45.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-08-30 at 13:24 -0700, Boaz Harrosh wrote: 
> On 08/30/2011 01:00 PM, Chuck Lever wrote:
> <>
> >> 
> >> Won't the above check be rather expensive? You'll need to do a 
> >> getxattr call on almost every path component of every lookup,
> >> right?
> >> 
> >> I may be misremembering your talk from connectathon, but I thought
> >> you were planning to use a well-known mode for junctions that would
> >> cut down on the number of unnecessary getxattrs...
> > 
> > Yes, that's the plan.  To reduce overhead, the S_ISVTX bit must be
> > set before NFSD does the expensive xattr test.  

...and mode bits otherwise set to 0 so nobody can access the mounted-on
directory.

> from: stat(2) - Linux man page
> 
> The 'sticky' bit (S_ISVTX) on a directory means that a file in that
> directory can be renamed or deleted only by the owner of the file, 
> by the owner of the directory, and by a privileged process.
> 
> Please explain how does it work? Once the junction is followed and
> mounted then the mode-bits get changed to the destination directory's
> mode bits? So the Server's junction mode-bits are never exposed, except
> in a local-fs file access on the server?

Yes.



-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

