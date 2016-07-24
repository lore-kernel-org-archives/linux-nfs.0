Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48870 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbcGXOXQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 10:23:16 -0400
Date: Sun, 24 Jul 2016 15:23:07 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Oleg Drokin <green@linuxhacker.ru>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/7] nfsd: remove redundant i_lookup check
Message-ID: <20160724142306.GO2356@ZenIV.linux.org.uk>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
 <1469209736-6490-4-git-send-email-bfields@redhat.com>
 <20160724002152.GN2356@ZenIV.linux.org.uk>
 <20160724121014.GA20985@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160724121014.GA20985@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 24, 2016 at 08:10:14AM -0400, J. Bruce Fields wrote:
> On Sun, Jul 24, 2016 at 01:22:06AM +0100, Al Viro wrote:
> > On Fri, Jul 22, 2016 at 01:48:52PM -0400, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > I'm not sure why this was added.  It doesn't seem necessary, and no
> > > other caller does this.
> > 
> > lookup_one_len() will explode if you call it for non-directory (==
> > !d_can_lookup(), i.e. something without ->lookup()).  So unless the callers
> > do guarantee that check being true, it *is* needed.
> 
> Both callers call fh_verify(.,.,S_IFDIR,.), so at this point we know
> that i_mode & S_IFMT == S_IFDIR.  Is there some odd case where that's
> insufficient?  If so, I think there may be bugs elsewhere in nfsd.  If
> not, I'll add a note to the changelog.

First of all, such objects do exist; they probably won't be encountered by
nfsd and all instances I can think of are not writable, but...

> Thanks for reminding me to check this, I hadn't thought of that as an
> "is this a directory" check, it makes more sense now.

I'd have turned that into d_can_lookup(fhp->fh_dentry), actually.
