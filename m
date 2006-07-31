From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] knfsd: Fix stale file handle problem with subtree_checking.
Date: Mon, 31 Jul 2006 12:16:33 -0400
Message-ID: <20060731161633.GB11459@fieldses.org>
References: <20060728194103.7245.patches@notabene> <1060728094255.7278@suse.de> <20060728205156.GB12183@fieldses.org> <17610.62013.790217.817455@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030209AbWGaQQn@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17610.62013.790217.817455@cse.unsw.edu.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Jul 29, 2006 at 03:29:33PM +1000, Neil Brown wrote:
> The first step would be to stop it from being the default (as Trond
> has suggested a number of times :-)
> 
> How about this.
>  I release a 1.0.10 shortly which addresses some 'portlist' related
>  breakage and prints a nasty warning if you have neither subtree_check
>  or no_subtree_check, but still defaults to subtree_check.
> 
>  Then the next release will be 1.1.0 which prints the same warning,
>  but defaults the other way - and probably removed the warning if you
>  include neither sync not async.
> 
> That should at least get subtree_check to be used less.

Sounds good to me.  (Though for these kinds of changes I suppose it's
the time elasped that matters more than the number of released
versions--people probably upgrade every x months/years/whatever rather
than every x versions.  By that criteria I think we might be making the
subtree_check change a little fast, while the warning period for the
sync change may already be overkill....)

> I think it is a great idea for a 'filesystem' to support multiple
> independent file-trees within the one storage set, which is roughly
> what you are saying I think (though probably not quite).
> 
> However I suspect that most people don't actually want subtrees.  They
> just get it as the default.  It isn't something that I would have
> implemented if I hadn't inherited the requirement, and no other OS
> that I know of provides that particular semantic.

Could be.

--b.
