Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38150 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940AbcGXMKQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Jul 2016 08:10:16 -0400
Date: Sun, 24 Jul 2016 08:10:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Oleg Drokin <green@linuxhacker.ru>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/7] nfsd: remove redundant i_lookup check
Message-ID: <20160724121014.GA20985@fieldses.org>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
 <1469209736-6490-4-git-send-email-bfields@redhat.com>
 <20160724002152.GN2356@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160724002152.GN2356@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 24, 2016 at 01:22:06AM +0100, Al Viro wrote:
> On Fri, Jul 22, 2016 at 01:48:52PM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > I'm not sure why this was added.  It doesn't seem necessary, and no
> > other caller does this.
> 
> lookup_one_len() will explode if you call it for non-directory (==
> !d_can_lookup(), i.e. something without ->lookup()).  So unless the callers
> do guarantee that check being true, it *is* needed.

Both callers call fh_verify(.,.,S_IFDIR,.), so at this point we know
that i_mode & S_IFMT == S_IFDIR.  Is there some odd case where that's
insufficient?  If so, I think there may be bugs elsewhere in nfsd.  If
not, I'll add a note to the changelog.

Thanks for reminding me to check this, I hadn't thought of that as an
"is this a directory" check, it makes more sense now.

--b.
