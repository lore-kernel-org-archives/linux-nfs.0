From: Paul Dickson <dickson@permanentmail.com>
Subject: Re: [PATCH 001 of 14] knfsd: Change the store of auth_domains to
 not be a 'cache'.
Date: Thu, 9 Mar 2006 09:26:37 -0700
Message-ID: <20060309092637.4d008f97.dickson@permanentmail.com>
References: <20060309174755.24381.patches@notabene>
	<1060309065127.24521@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: akpm@osdl.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHNyb-0007MZ-AS
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 08:26:57 -0800
Received: from rune.pobox.com ([208.210.124.79])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FHNyZ-0004HX-2P
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 08:26:57 -0800
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060309065127.24521@suse.de>
Sender: nfs-admin@lists.sourceforge.net
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

On Thu, 9 Mar 2006 17:51:27 +1100, NeilBrown wrote:

>  struct auth_domain *unix_domain_find(char *name)
>  {
> - [code deletions removed]
> +	struct auth_domain *rv;
> +	struct unix_domain *new = NULL;
>  
> - [code deletions removed]
> +	rv = auth_domain_lookup(name, NULL);
> +	while(1) {
> +		if (rv != &new->h) {
> +			if (new) auth_domain_put(&new->h);
> +			return rv;
> +		}

> +		new = kmalloc(sizeof(*new), GFP_KERNEL);
> +		if (new == NULL)
> +			return NULL;

My C skills are a bit rusty, but is seems the value of new is offsetted
while still NULL.  I could not find any further updates in the patch
series.

	-Paul



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
