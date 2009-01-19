From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Mon, 19 Jan 2009 08:23:14 +0530
Message-ID: <1232333594.3129.31.camel@localhost.localdomain>
References: <1232223441.3966.22.camel@localhost.localdomain>
	 <20090119112429.78f5dc33.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	linux-media@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
	dbrownell@users.sourceforge.net,
	spi-devel-general@lists.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org, dwmw2@infradead.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <20090119112429.78f5dc33.sfr@canb.auug.org.au>
Sender: linux-media-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-01-19 at 11:24 +1100, Stephen Rothwell wrote:
> On Sun, 18 Jan 2009 01:47:21 +0530 Jaswinder Singh Rajput <jaswinder@kernel.org> wrote:
> >
> > diff --git a/include/linux/nfsd/stats.h b/include/linux/nfsd/stats.h
> > index 7678cfb..0b53cfe 100644
> > --- a/include/linux/nfsd/stats.h
> > +++ b/include/linux/nfsd/stats.h
> > @@ -29,9 +29,11 @@ struct nfsd_stats {
> >  	unsigned int	ra_size;	/* size of ra cache */
> >  	unsigned int	ra_depth[11];	/* number of times ra entry was found that deep
> >  					 * in the cache (10percentiles). [10] = not found */
> > +#ifdef __KERNEL__
> >  #ifdef CONFIG_NFSD_V4
> >  	unsigned int	nfs4_opcount[LAST_NFS4_OP + 1];	/* count of individual nfsv4 operations */
> >  #endif
> > +#endif /* __KERNEL__ */
> >  
> >  };
> 
> The only variable in the kernel of type "struct nfsd_stats" is only
> exported to user mode via procfs, so this whole structure could probably
> go inside __KERNEL__.  Then looking harder, I wonder if this header
> should be exported to user mode at all.
> 

I was in doubt may be this will be used by some userspace utilities.

Once I got confirmation that it is not required in userspace, I will
remove it :-)

--
JSR

