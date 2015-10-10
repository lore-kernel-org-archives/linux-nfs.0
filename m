Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60278 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbbJJRNU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Oct 2015 13:13:20 -0400
Date: Sat, 10 Oct 2015 18:13:17 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Leandro Awa <lawa@nvidia.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] namei: results of d_is_negative() should be checked
 after dentry revalidation
Message-ID: <20151010171317.GF22011@ZenIV.linux.org.uk>
References: <9459055931ab4f269b96bad953738778@HQMAIL102.nvidia.com>
 <1444412674-3077-1-git-send-email-trond.myklebust@primarydata.com>
 <CA+55aFzMMEB_zLoS+SznZCiW8k3ZgMO4BBFFJz7=Cj99FXiXmQ@mail.gmail.com>
 <20151010013657.GD22011@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151010013657.GD22011@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 10, 2015 at 02:36:57AM +0100, Al Viro wrote:
> On Fri, Oct 09, 2015 at 05:19:02PM -0700, Linus Torvalds wrote:
> 
> > So in general, we should always (a) either verify all sequence points
> > or (b) return -ENOCHLD to go into slow mode. The patch seems
> > 
> > However, this thing was explicitly made to be this way by commit
> > 766c4cbfacd8 ("namei: d_is_negative() should be checked before ->d_seq
> > validation"), so while my gut feel is to consider this fix
> > ObviouslyCorrect(tm), I will delay it a bit in the hope to get an ACK
> > and comment from Al about the patch.
> > 
> > Al?
> 
> Umm...  I agree that the current version is wrong and it looks like this
> patch is a complete fix.  The only problem is the commit message -
> what really happens is that 766c4cbfacd8 got the things subtly wrong.
> We used to treat d_is_negative() after lookup_fast() as "fall with ENOENT".
> That was wrong - checking ->d_flags outside of ->d_seq protection is
> unreliable and failing with hard error on what should've fallen back to
> non-RCU pathname resolution is a bug.
> 
> Unfortunately, we'd pulled the test too far up and ran afoul of another
> kind of staleness.  Dentry might have been absolutely stable from the
> RCU point of view (and we might be on UP, etc.), but stale from the
> remote fs point of view.  If ->d_revalidate() returns "it's actually
> stale", dentry gets thrown away and original code wouldn't even have looked
> at its ->d_flags.  What we need is to check ->d_flags where 766c4cbfacd8 does
> (prior to ->d_seq validation) but only use the result in cases where we
> do not discard this dentry outright.
> 
> With some explanation along the lines of the above added, consider the patch
> ACKed.

OK, I've attemtped to add an explanation of what's going on; please, pull from
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-linus

Shortlog:
Trond Myklebust (1):
      namei: results of d_is_negative() should be acted upon only after dentry revalidation

Diffstat:
 fs/namei.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

