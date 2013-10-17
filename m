Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53262 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957Ab3JQNSO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Oct 2013 09:18:14 -0400
Date: Thu, 17 Oct 2013 09:18:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Wangminlan <wangminlan@huawei.com>, Neil Brown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Different sequence of "exportfs" produce different effects on
 nfs client mounts
Message-ID: <20131017131810.GG19067@fieldses.org>
References: <3962238FD7EA0F41B1810E7ABEAFBC314CEF9ACF@szxema505-mbs.china.huawei.com>
 <20131014174540.GA27747@fieldses.org>
 <3962238FD7EA0F41B1810E7ABEAFBC314CEF9E97@szxema505-mbs.china.huawei.com>
 <20131015154918.GA6117@fieldses.org>
 <3962238FD7EA0F41B1810E7ABEAFBC314CEF9FD9@szxema505-mbs.china.huawei.com>
 <3962238FD7EA0F41B1810E7ABEAFBC314CEFA2F5@szxema505-mbs.china.huawei.com>
 <CB4DB7B1-5EEA-47D0-9CAD-CC69AF868182@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CB4DB7B1-5EEA-47D0-9CAD-CC69AF868182@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 17, 2013 at 09:14:02AM -0400, Chuck Lever wrote:
> Hi-
> 
> 281         if (ident[0] == '\0')
> 282                 return MCL_ANONYMOUS;
> 283         if (ident[0] == '@') {
> 284 #ifndef HAVE_INNETGR
> 285                 xlog(L_WARNING, "netgroup support not compiled in");
> 286 #endif
> 287                 return MCL_NETGROUP;
> 288         }
> 289         for (sp = ident; *sp; sp++) {
> 290                 if (*sp == '*' || *sp == '?' || *sp == '[')
> 291                         return MCL_WILDCARD;
> 292                 if (*sp == '/')
> 293                         return MCL_SUBNETWORK;
> 294                 if (*sp == '\\' && sp[1])
> 295                         sp++;
> 296         }
> 
> is still in play today.  The "host_pton()" code you posted was added by commit 502edf1d just after this paragraph.  But here is what that commit replaced.
> 
> -       /* check for N.N.N.N */
> -       sp = ident;
> -       if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_FQDN;
> -       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_F
> -       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_F
> -       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '\0') return MCL_
> -       /* we lie here a bit. but technically N.N.N.N == N.N.N.N/32 :) */
> -       return MCL_SUBNETWORK;
> +
> +       /*
> +        * Treat unadorned IP addresses as MCL_SUBNETWORK.
> +        * Everything else is MCL_FQDN.
> +        */
> +       ai = host_pton(ident);
> +       if (ai != NULL) {
> +               freeaddrinfo(ai);
> +               return MCL_SUBNETWORK;
> +       }
> +
> +       return MCL_FQDN;
>  }
> 
> The replaced logic also treats IP addresses as MCL_SUBNETWORK.  That's from commit 54669c98 in 2005.  Neil, do you remember why this semantic change was made?

Um, sorry Neil, looks like Chuck and I were both searching the git logs
at the same time!

--b.
