Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38727 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753315Ab2KIUHd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Nov 2012 15:07:33 -0500
Date: Fri, 9 Nov 2012 15:07:30 -0500
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org, Eldad Zack <eldad@fogrefinery.com>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121109200730.GI6171@fieldses.org>
References: <k6ebva$1kf$1@ultimate100.geggus.net>
 <20121026171549.GA11806@fieldses.org>
 <20121029094038.GA14836@geggus.net>
 <20121029150203.GB9502@fieldses.org>
 <20121105165459.GA2958@geggus.net>
 <k7jj0c$nak$1@ultimate100.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <k7jj0c$nak$1@ultimate100.geggus.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 09, 2012 at 06:45:32PM +0000, Sven Geggus wrote:
> Sven Geggus <lists@fuchsschwanzdomain.de> wrote:
> 
> > OK, I now figured out which commit did cause the problem:
> > 
> > Thus "git diff 08843b79..cc8362b1" on a linux-stable tree from
> > git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git should
> > give us the relevant changes.
> 
> After a private conversation with J. Bruce Fields I figured out that
> I have not been quite there yet. So here comes a FTR post what
> exactly caused my problem.

Thanks for tracking this down--not what I would have guessed!

Given that the trace showed a problem starting around context creation
time, I'm most suspicious of the callers in rsc_parse, which are mostly
parsing uid's.

Is it possible that your system has very large uid's?  (Large enough
that they'd look like negative numbers when cast to ints?)

Output from

	strace -p $(pidof rpc.mountd) -s4096 -e trace=open,close,read,write

(while reproducing the bug) might help confirm that.

--b.


> 
> It is the following change:
> 
> $ git diff d9c2ede63c74048dfddbb129c59ac01176b0ab71 bbf43dc888833ac0539e437dbaeb28bfd4fbab9f
> diff --git a/include/linux/sunrpc/cache.h
> b/include/linux/sunrpc/cache.h
> index 6def1f6..af42596 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -217,8 +217,6 @@ extern int qword_get(char **bpp, char *dest, int
> bufsize);
>  static inline int get_int(char **bpp, int *anint)
>  {
>         char buf[50];
> -       char *ep;
> -       int rv;
>         int len = qword_get(bpp, buf, sizeof(buf));
>  
>         if (len < 0)
> @@ -226,11 +224,9 @@ static inline int get_int(char **bpp, int
> *anint)
>         if (len == 0)
>                 return -ENOENT;
>  
> -       rv = simple_strtol(buf, &ep, 0);
> -       if (*ep)
> +       if (kstrtoint(buf, 0, anint))
>                 return -EINVAL;
>  
> -       *anint = rv;
>         return 0;
>  }
> 
> Reverting this change on recent kernels makes them work for me again.
> 
> Sven
> 
> 
> -- 
> Unix is simple and coherent, but it takes a genius – or at any rate a
> programmer – to understand and appreciate the simplicity
> (Dennis M. Ritchie)
> /me is giggls@ircnet, http://sven.gegg.us/ on the Web
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
