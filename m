From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/6] NLM: Support IPv6 scope IDs in
	nlm_display_address()
Date: Wed, 3 Dec 2008 14:46:47 -0500
Message-ID: <20081203194647.GN16846@fieldses.org>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net> <20081201185741.10600.7375.stgit@ingres.1015granger.net> <20081203193404.GM16846@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49942 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701AbYLCTqv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Dec 2008 14:46:51 -0500
In-Reply-To: <20081203193404.GM16846@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 03, 2008 at 02:34:04PM -0500, bfields wrote:
> On Mon, Dec 01, 2008 at 01:57:42PM -0500, Chuck Lever wrote:
> > --- a/include/linux/lockd/lockd.h
> > +++ b/include/linux/lockd/lockd.h
> > @@ -75,7 +75,7 @@ struct nsm_handle {
> >  	size_t			sm_addrlen;
> >  	unsigned int		sm_monitored : 1,
> >  				sm_sticky : 1;	/* don't unmonitor */
> > -	char			sm_addrbuf[48];	/* address eyecatcher */
> > +	char			sm_addrbuf[63];	/* presentation address */
> >  };
> 
> Could you add a brief (1-line?) comment justifying the choice of 63?

So something like just:


 				sm_sticky : 1;	/* don't unmonitor */
	unsigned int		sm_monitored : 1,
				sm_sticky : 1;	/* don't unmonitor */
/*
 * This can hold 8 groups of colon-separated 4-hex-digit numbers, a
 * percent sign, and a scope id (at most 32 bits, in decimal, so):
 * 63 == 8*4 + 7 colons + 1 percent sign + at most 10 digits + padding:
 */
	char			sm_addrbuf[63];	/* presentation address */
