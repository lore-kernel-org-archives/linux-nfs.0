From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC: 2.6 patch] net/sunrpc/: possible cleanups
Date: Sun, 2 Oct 2005 16:41:13 +0200
Message-ID: <20051002144113.GM4212@stusta.de>
References: <20051001142041.GB4212@stusta.de> <20051001164019.GB8633@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, neilb@cse.unsw.edu.au,
	trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751096AbVJBOlT@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20051001164019.GB8633@mipter.zuzino.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Oct 01, 2005 at 08:40:19PM +0400, Alexey Dobriyan wrote:
> On Sat, Oct 01, 2005 at 04:20:41PM +0200, Adrian Bunk wrote:
> > -/* Just increments the mechanism's reference count and returns its input: */
> > -struct gss_api_mech * gss_mech_get(struct gss_api_mech *);
> > -
> 
> > -struct gss_api_mech *
> > +static struct gss_api_mech *
> >  gss_mech_get(struct gss_api_mech *gm)
> 
> Comment is lost.


The comment made sense for the prototype at the header, but the function 
now has only one caller in the file where it's defined.


If someone needs a comment to figure out what a function whose complete 
contents is

static struct gss_api_mech *
gss_mech_get(struct gss_api_mech *gm)
{
        __module_get(gm->gm_owner);
        return gm;
}

does, the problem is not a missing comment.


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
