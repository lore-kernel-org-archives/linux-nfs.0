From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] auth_domain_lookup in 2.6.8-rc2
Date: Fri, 8 Oct 2004 15:43:06 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041008194306.GH15184@fieldses.org>
References: <20041008100102.GA20142@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CG0e1-0002Fu-P2
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 12:43:13 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CG0dy-0003HW-AC
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 12:43:13 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041008100102.GA20142@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, Oct 08, 2004 at 12:01:03PM +0200, Olaf Kirch wrote:
> 2.6.8-rc2 open-codes auth_domain_lookup, and introduces a flaw that
> may have security consequences. If we do not find any matching
> domain, the routine always returns the last item looked at, no
> matter what it was.

Argh, sorry, that was my fault.  Thanks for spotting it.--b.

> This patch makes sure that auth_domain_lookup returns NULL when
> it doesn't find a matching entry, rather than the last entry
> in the hash chain.
> 
> Signed-off-by: Olaf Kirch <okir@suse.de>
> 
> Index: linux-2.6.8/net/sunrpc/svcauth.c
> ===================================================================
> --- linux-2.6.8.orig/net/sunrpc/svcauth.c
> +++ linux-2.6.8/net/sunrpc/svcauth.c
> @@ -183,7 +183,7 @@ auth_domain_lookup(struct auth_domain *i
>  	}
>  	/* Didn't find anything */
>  	if (!set)
> -		goto out_noset;
> +		goto out_nada;
>  	auth_domain_cache.entries++;
>  out_set:
>  	set_bit(CACHE_HASHED, &item->h.flags);
> @@ -193,6 +193,8 @@ out_set:
>  	cache_fresh(&auth_domain_cache, &item->h, item->h.expiry_time);
>  	cache_get(&item->h);
>  	return item;
> +out_nada:
> +	tmp = NULL;
>  out_noset:
>  	read_unlock(&auth_domain_cache.hash_lock);
>  	return tmp;



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
