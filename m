From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [2.6 patch] net/sunrpc/xdr.c: remove xdr_decode_string()
Date: Wed, 23 Nov 2005 22:56:51 -0800
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E2013327ED@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: "David Miller" <davem@davemloft.net>, <trond.myklebust@fys.uio.no>,
	<linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161026AbVKXG5I@vger.kernel.org>
To: "Neil Brown" <neilb@suse.de>, "Adrian Bunk" <bunk@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

> On Wednesday November 23, bunk@stusta.de wrote:
> > On Wed, Nov 23, 2005 at 04:31:14AM -0800, Lever, Charles wrote:
> > > so i don't remember why you are removing 
> xdr_decode_string.  are we sure
> > > that no-one will need this functionality in the future?  
> it is harmless
> > > to remove today, but i wonder if someone is just going to 
> add it back
> > > sometime.
> > 
> > It's unused and you said:
> >   the only harmless change i see below is removing 
> xdr_decode_string().
> > 
> 
> As 'xdr_decode_string' (sometimes) modifies the buffer that it is
> decoding, I don't think it's usage should be encouraged.  If it is no
> longer in use, then I fully support and encourage removing it.

actually this is a good point.  since it is unused, it is an untested
path as we continue to evolve the code base.
