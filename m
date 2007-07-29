From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 01/23] mount.nfs: Support double-wide characters
	in printed	strings
Date: Sun, 29 Jul 2007 17:39:06 +1000
Message-ID: <18092.17434.520955.494157@notabene.brown>
References: <20070728214913.21871.41624.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IF3N7-0004h2-M5
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 00:39:25 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IF3NB-0003qk-5o
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 00:39:29 -0700
In-Reply-To: message from Chuck Lever on Saturday July 28
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

On Saturday July 28, chuck.lever@oracle.com wrote:
> NLS changes missed a spot or two.
> 
> @@ -105,7 +106,7 @@ void mount_errors(char *server, int will_retry, int bg)
>  			openlog("mount", LOG_CONS|LOG_PID, LOG_AUTH);
>  		syslog(LOG_ERR, "%s.", errbuf);
>  	} else
> -		fprintf(stderr, "%s.\n", errbuf);
> +		fprintf(stderr, _("%s.\n"), errbuf);
>  }

Do we really want NLS support for putting a full stop at the end of a
line?
>  		if (opts != NULL)
> -			printf(" (%s)", opts);
> +			printf(_(" (%s)"), opts);

and putting something in parentheses

>  
> -		printf("\n");
> +		printf(_("\n"));

and for a single newline?

> index 26a6896..bd20864 100644
> --- a/utils/mount/nfs4mount.c
> +++ b/utils/mount/nfs4mount.c
> @@ -160,7 +160,7 @@ static int get_my_ipv4addr(char *ip_addr, int len)
>  	}
>  	if (fill_ipv4_sockaddr(myname, &myaddr))
>  		return -1;
> -	snprintf(ip_addr, len, "%s", inet_ntoa(myaddr.sin_addr));
> +	snprintf(ip_addr, len, _("%s"), inet_ntoa(myaddr.sin_addr));

Why this change?  Does it achieve anything?


>  	}
> -	snprintf(new_opts, sizeof(new_opts), "%s%saddr=%s",
> -		 old_opts, *old_opts ? "," : "", s);
> +	snprintf(new_opts, sizeof(new_opts), _("%s%saddr=%s"),
> +		 old_opts, *old_opts ? _(",") : _(""), s);
>  	*extra_opts = xstrdup(new_opts);

????


> -				snprintf(ip_addr, sizeof(ip_addr), "%s",
> +				snprintf(ip_addr, sizeof(ip_addr), _("%s"),

???


Maybe I'm mistaken, but I thought _(xxx) was just to allow
localisations to provide different translations of xxx.  When it is
something like punctuation - particularly an end-of-line character - 
I don't think I see the point.
Also you seem to have added it when building up option lists, and I
don't think it makes sense to translate those.

So please either show me the error of my thinking, or stick to adding
_() to translatable strings.

Much of this patch is good and wanted, I'm not sure about the whole.
Similarly for patch 2.

I only got 12 of the 23 patches??

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
