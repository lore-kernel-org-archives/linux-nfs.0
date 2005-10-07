From: Neil Brown <neilb@suse.de>
Subject: Re: Small nfs-utils patch
Date: Fri, 7 Oct 2005 14:47:12 +1000
Message-ID: <17221.64976.852023.657826@cse.unsw.edu.au>
References: <20050523101557.GD24634@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENk8k-0003eE-KF
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 21:47:26 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ENk8j-0004u0-DI
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 21:47:26 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id AE881EC86
	for <nfs@lists.sourceforge.net>; Fri,  7 Oct 2005 06:47:20 +0200 (CEST)
To: Olaf Kirch <okir@suse.de>
In-Reply-To: message from Olaf Kirch on Monday May 23
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

On Monday May 23, okir@suse.de wrote:
> Without this patch, showmount -e would sometimes display
> host names that should really have been subsumed under a
> wildcard entry.
> 
> The problem was that the code in get_exportlist would always
> skip the next group entry after removing one FQDN.

Thanks.  I've committed it to the sourceforge CVS.
(Hey, turn-around of less than 5 months! You can't complain 
about that!! :-) 

NeilBrown

> 
> Olaf
> -- 
> Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
> okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
> 
> Without this patch, showmount -e would sometimes display
> host names that should really have been subsumed under a
> wildcard entry.
> 
> The problem was that the code in get_exportlist would always
> skip the next group entry after removing one FQDN.
> 
> Signed-off-by: Olaf Kirch <okir@suse.de>
> 
> Index: nfs-utils-1.0.7/utils/mountd/mountd.c
> ===================================================================
> --- nfs-utils-1.0.7.orig/utils/mountd/mountd.c
> +++ nfs-utils-1.0.7/utils/mountd/mountd.c
> @@ -409,11 +409,9 @@ get_exportlist(void)
>  				xfree(c->gr_name);
>  				xfree(c);
>  				xfree (hp);
> -				if ((c = *cp) == NULL)
> -				  break;
> +				continue;
>  			      }
> -			      else
> -				xfree (hp);
> +			      xfree (hp);
>  			    }
>  			    cp = &(c->gr_next);
>  			  }


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
