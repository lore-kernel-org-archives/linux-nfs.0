From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] net/sunrpc/xdr.c: remove xdr_decode_string()
Date: Wed, 23 Nov 2005 17:25:28 +0100
Message-ID: <20051123162528.GL3963@stusta.de>
References: <044B81DE141D7443BCE91E8F44B3C1E2013327DF@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, neilb@cse.unsw.edu.au,
	trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751229AbVKWQZn@vger.kernel.org>
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E2013327DF@exsvl02.hq.netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Nov 23, 2005 at 04:31:14AM -0800, Lever, Charles wrote:
> > On Thu, Oct 06, 2005 at 07:13:14AM -0700, Lever, Charles wrote:
> > 
> > > actually, can we hold off on this change?  the RPC 
> > transport switch will
> > > eventually need most of those EXPORT_SYMBOLs.
> > 
> > Am I right to assume this will happen in the foreseeable future?
> 
> the first portion of the transport switch is in 2.6.15-rcX.  at this
> point i'm expecting the EXPORT_SYMBOL changes to go in 2.6.17 or later.

OK.

> so i don't remember why you are removing xdr_decode_string.  are we sure
> that no-one will need this functionality in the future?  it is harmless
> to remove today, but i wonder if someone is just going to add it back
> sometime.

It's unused and you said:
  the only harmless change i see below is removing xdr_decode_string().

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
