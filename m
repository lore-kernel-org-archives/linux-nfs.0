From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 3/7] sunrpc/cache: change deferred-request hash table to
 use hlist.
Date: Wed, 22 Sep 2010 14:51:13 +1000
Message-ID: <20100922145113.30ede403@notabene>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
	<20100922025506.31745.9409.stgit@localhost.localdomain>
	<20100922025944.GC22021@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57451 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750730Ab0IVEvU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 00:51:20 -0400
In-Reply-To: <20100922025944.GC22021@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 21 Sep 2010 22:59:44 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Sep 22, 2010 at 12:55:07PM +1000, NeilBrown wrote:
> > Being a hash table, hlist is the best option.
> > 
> > There is currently some ugliness were we treat "->next == NULL" as
> > a special case to avoid having to initialise the whole array.
> > This change nicely gets rid of that case.
> 
> This (or some hopefully correct variant!) should already be applied;
> could you check that it looks right?

I must has pulled just a little too early - I see it now.
Just a couple of minor formatting improvements in your version, otherwise
identical.

Thanks,
NeilBrown
