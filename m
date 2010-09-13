Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61644 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753283Ab0IMQ4S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 12:56:18 -0400
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Christoph Hellwig <hch@infradead.org>, Fred Isaman <iisaman@netapp.com>,
        linux-nfs@vger.kernel.org
In-Reply-To: <4C8E3733.2000607@panasas.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	 <1283450419-5648-8-git-send-email-iisaman@netapp.com>
	 <20100910235858.GB11231@infradead.org>
	 <1284163679.14078.106.camel@heimdal.trondhjem.org>
	 <4C8E0A03.3020500@panasas.com>
	 <1284380997.2825.2.camel@heimdal.trondhjem.org>
	 <4C8E3733.2000607@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 13 Sep 2010 12:55:14 -0400
Message-ID: <1284396914.6466.7.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-09-13 at 16:37 +0200, Benny Halevy wrote:
> On 2010-09-13 14:29, Trond Myklebust wrote:
> > On Mon, 2010-09-13 at 13:24 +0200, Benny Halevy wrote:
> >> On 2010-09-11 03:07, Trond Myklebust wrote:
> >>> On Fri, 2010-09-10 at 19:58 -0400, Christoph Hellwig wrote:
> >>>>> +EXPORT_SYMBOL(pnfs_register_layoutdriver);
> >>>>
> >>>> Al exports from nfs.ko needs to be _GPL - this is in no way a public
> >>>> API, just an internal subdivision of the nfs client.
> >>>
> >>> ACK. We're not committing to supporting a stable ABI here in any way,
> >>> shape or form...
> >>
> >> OK, not yet.
> >>
> >> However, on the longer run I'd like us to consider formalizing
> >> the kABI for non-GPLed layout drivers.
> >>
> >> I think that this is a great selling point as it fully materializes the
> >> extensibility of the layout-type / layout-driver design model.
> > 
> > No. I'm not committing to a kabi, ever...
> 
> Care to explain your reasoning in some more details?

It has already been laid out in Documentation/stable_api_nonsense.txt.
It boils down to the following:

 1) I don't _ever_ want to have to deal with debugging problems that
might involve binary-only modules.
 2) I want to be able to change interfaces in order to optimise/improve
the code as needed without having to check in with a bunch of
out-of-tree maintainers about whether or not it is 'OK' to do so.
 3) I don't see a need for linking to non-GPLed code.

Trond
