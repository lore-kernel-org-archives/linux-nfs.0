Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32944 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752739Ab1I3Oa5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Sep 2011 10:30:57 -0400
Date: Fri, 30 Sep 2011 10:30:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 1/3] NFSD: Added fault injection
Message-ID: <20110930143053.GB19125@fieldses.org>
References: <1317322765-19094-1-git-send-email-bjschuma@netapp.com>
 <A7558C0C-378A-42E3-AC37-8152C50972DB@oracle.com>
 <4E84D1B8.20903@netapp.com>
 <F9CDB8C6-E680-4373-81CD-CA8E8A635F84@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F9CDB8C6-E680-4373-81CD-CA8E8A635F84@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 30, 2011 at 10:28:02AM -0400, Chuck Lever wrote:
> 
> On Sep 29, 2011, at 4:14 PM, Bryan Schumaker wrote:
> 
> > On 09/29/2011 03:06 PM, Chuck Lever wrote:
> >> 
> >> On Sep 29, 2011, at 2:59 PM, bjschuma@netapp.com wrote:
> >> 
> >>> From: Bryan Schumaker <bjschuma@netapp.com>
> >>> 
> > ...
> >>> diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
> >>> index 9b118ee..69eae75 100644
> >>> --- a/fs/nfsd/Makefile
> >>> +++ b/fs/nfsd/Makefile
> >>> @@ -5,7 +5,8 @@
> >>> obj-$(CONFIG_NFSD)	+= nfsd.o
> >>> 
> >>> nfsd-y 			:= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
> >>> -			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
> >>> +			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o \
> >>> +			   fault_inject.o
> >>> nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
> >>> nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
> >>> nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
> >>> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> >>> new file mode 100644
> >>> index 0000000..2139883
> >>> --- /dev/null
> >>> +++ b/fs/nfsd/fault_inject.c
> >>> @@ -0,0 +1,102 @@
> >>> +#ifdef CONFIG_NFSD_FAULT_INJECTION
> >> 
> >> The usual practice is to conditionally compile this source file via a Makefile variable, not by wrapping the whole source file in an ifdef.  You can see examples of this in the Makefile hunk above.
> >> 
> > 
> > How's this?  I moved the selectively compile bit to the makefile and created a fault_inject.h for the empty init() and cleanup() functions.  I moved the rest of the fault injection function declarations there, too, to keep them all together.
> 
> OK.  How about adding documenting block comments for the new files?  Does NetApp require you to add a copyright notice at the top of new files?

You probably do want that, but just keep it to a minimum and don't
include the filename in the block comment.

--b.

> Also, I wonder if it would be better if you added "default N" for the
> new CONFIG option.

