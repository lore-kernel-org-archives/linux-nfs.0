From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Updated Next/Trees, problems with nfs-git
Date: Mon, 4 Aug 2008 13:35:56 -0400
Message-ID: <20080804173556.GA25940@fieldses.org>
References: <20080804134444.GC4182@denkbrett.schottelius.org> <20080804150940.GF4182@denkbrett.schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-nfs@vger.kernel.org
To: Nico -telmich- Schottelius <nico-linux-next@schottelius.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080804150940.GF4182@denkbrett.schottelius.org>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 04, 2008 at 05:09:40PM +0200, Nico -telmich- Schottelius wrote:
> Hello again!
> 
> Found out that #linux-next should have been #nfsd-next and updated
> the patch to match.
> 
> Patch attached.

I'm lost:

> -nfs		git	git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git#linux-next
> +nfs		git	git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git#nfsd-next

There is no branch named "nfsd-next" in that git repository.  (Do I
misunderstand how this file is supposed to work?)  The only nfsd-next I
know of is the one I push to at:

	git://linux-nfs.org/~bfields/linux.git nfsd-next

--b.
