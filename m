Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42382 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757180Ab3BVWSi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 17:18:38 -0500
Date: Fri, 22 Feb 2013 17:18:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: handle vfs_getattr errors in acl protocol
Message-ID: <20130222221835.GC30856@fieldses.org>
References: <20130201131537.GC30668@fieldses.org>
 <20130201185721.GP4503@ZenIV.linux.org.uk>
 <20130201201304.GE30668@fieldses.org>
 <20130222214634.GB30856@fieldses.org>
 <20130222221506.GM4503@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130222221506.GM4503@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 22, 2013 at 10:15:06PM +0000, Al Viro wrote:
> On Fri, Feb 22, 2013 at 04:46:34PM -0500, J. Bruce Fields wrote:
> 
> > > Actually, we have precisely the same interface except for the name:
> > > 
> > > 	__be32 fh_getattr(struct svc_fh *fh, struct kstat *stat)
> > > vs.
> > > 	__be32 nfsd_getattr(struct svc_fh *fh, struct kstat *stat)
> > > 
> > > but I'm fine with your name.
> > > 
> > > Do you want to take these patches, or should I?
> 
> *blink*
> 
> I blame being very low on caffeine; that, or being a blind idiot...
> My apologies ;-/
>
> > I guess what I'll do unless I hear otherwise is apply both your patch
> > and mine to my tree for 3.9.
> 
> FWIW, I'm going to push the first part of VFS queue later tonight...

OK, I'll wait and see what's in that.

(And what should I do with the delegation patches?)

--b.
