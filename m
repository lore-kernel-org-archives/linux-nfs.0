From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [PATCH] 2.5.42: build nfsd as module broken
Date: Sat, 12 Oct 2002 14:26:31 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.GSO.4.21.0210121423500.6898-100000@steklov.math.psu.edu>
References: <871y6vwmft.fsf@goat.bogus.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Olaf Dietsche <olaf.dietsche#list.linux-kernel@t-online.de>
In-Reply-To: <871y6vwmft.fsf@goat.bogus.local>
List-ID: <nfs.lists.sourceforge.net>



On Sat, 12 Oct 2002, Olaf Dietsche wrote:

> +EXPORT_SYMBOL(cache_fresh);
> +EXPORT_SYMBOL(cache_flush);
> +EXPORT_SYMBOL(cache_unregister);
> +EXPORT_SYMBOL(cache_check);
> +EXPORT_SYMBOL(cache_clean);
> +EXPORT_SYMBOL(cache_register);
> +EXPORT_SYMBOL(cache_init);
> +EXPORT_SYMBOL(add_word);
> +EXPORT_SYMBOL(add_hex);
> +EXPORT_SYMBOL(get_word);

Ahem.  Non-static objects called add_word and get_word?  Even the cache_...()
stuff is a namespace pollution (which kind of cache?), but that...
