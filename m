From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] 2.5.42: build nfsd as module broken
Date: Sun, 13 Oct 2002 09:51:32 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15784.46468.880128.458867@notabene.cse.unsw.edu.au>
References: <871y6vwmft.fsf@goat.bogus.local>
	<Pine.GSO.4.21.0210121423500.6898-100000@steklov.math.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Dietsche <olaf.dietsche#list.linux-kernel@t-online.de>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <viro@math.psu.edu>)
	(for <olaf.dietsche#list.linux-kernel@t-online.de>)
	(for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By tone With Smtp ;
	Sun, 13 Oct 2002 09:51:39 +1000
To: Alexander Viro <viro@math.psu.edu>
In-Reply-To: message from Alexander Viro on Saturday October 12
List-ID: <nfs.lists.sourceforge.net>

On Saturday October 12, viro@math.psu.edu wrote:
> 
> 
> On Sat, 12 Oct 2002, Olaf Dietsche wrote:
> 
> > +EXPORT_SYMBOL(cache_fresh);
> > +EXPORT_SYMBOL(cache_flush);
> > +EXPORT_SYMBOL(cache_unregister);
> > +EXPORT_SYMBOL(cache_check);
> > +EXPORT_SYMBOL(cache_clean);
> > +EXPORT_SYMBOL(cache_register);
> > +EXPORT_SYMBOL(cache_init);
> > +EXPORT_SYMBOL(add_word);
> > +EXPORT_SYMBOL(add_hex);
> > +EXPORT_SYMBOL(get_word);
> 
> Ahem.  Non-static objects called add_word and get_word?  Even the cache_...()
> stuff is a namespace pollution (which kind of cache?), but that...

Fair comment.

The words are actually 'quoted words', so maybe:

 qword_add
 qword_addhex
 qword_parse  (or qword_get) 

 would be better.

The caches are for caching user-space-sourced information (IP ->
hostname, export options, uid->username etc) so maybe

  ucache_*
though that is a bit bland....

  uss_cache_*

(for the trekkies)???

NeilBrown
