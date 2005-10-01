From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC: 2.6 patch] net/sunrpc/: possible cleanups
Date: Sat, 1 Oct 2005 20:40:19 +0400
Message-ID: <20051001164019.GB8633@mipter.zuzino.mipt.ru>
References: <20051001142041.GB4212@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, neilb@cse.unsw.edu.au,
	trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750814AbVJAQ3L@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20051001142041.GB4212@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Oct 01, 2005 at 04:20:41PM +0200, Adrian Bunk wrote:
> -/* Just increments the mechanism's reference count and returns its input: */
> -struct gss_api_mech * gss_mech_get(struct gss_api_mech *);
> -

> -struct gss_api_mech *
> +static struct gss_api_mech *
>  gss_mech_get(struct gss_api_mech *gm)

Comment is lost.
