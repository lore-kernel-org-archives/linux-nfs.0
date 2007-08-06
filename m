From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] fix regression with rmtab handling in newer
	nfs-utils code
Date: Tue, 7 Aug 2007 09:55:17 +1000
Message-ID: <18103.46309.986672.548820@notabene.brown>
References: <20070806155500.25869737.jlayton@redhat.com>
	<4d569c330708061501n501e37dcr6d98800618b4ea4d@mail.gmail.com>
	<20070806191858.0afaaa91.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: iisaman@citi.umich.edu, nfs@lists.sourceforge.net,
	Kevin Coffman <kwc@citi.umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IICQ3-0001Ba-GX
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 16:55:27 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IICQ5-0008SH-CK
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 16:55:31 -0700
In-Reply-To: message from Jeff Layton on Monday August 6
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Monday August 6, jlayton@redhat.com wrote:
> 
> No problem. I just wanted to make sure I wasn't missing something. I
> think this patch against the current git tree should fix it:

Thanks.  Applied.

NeilBrown

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index b686318..15100d4 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -649,8 +649,7 @@ void nfsd_export(FILE *f)
>  			     "Cannot export %s, possibly unsupported filesystem"
>  			     " or fsid= required", path);
>  			dump_to_cache(f, dom, path, NULL);
> -		} else
> -			mountlist_add(dom, path);
> +		}
>  	} else {
>  		dump_to_cache(f, dom, path, NULL);
>  	}
> @@ -729,7 +728,6 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
>  		     "Cannot export %s, possibly unsupported filesystem or"
>  		     " fsid= required", exp->e_path);
>  	}
> -	mountlist_add(domain, exp->e_path);
>  
>  	while (err == 0 && (exp->e_flags & NFSEXP_CROSSMOUNT) && path) {
>  		/* really an 'if', but we can break out of

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
