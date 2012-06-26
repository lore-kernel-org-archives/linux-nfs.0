Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755420Ab2FZDRq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jun 2012 23:17:46 -0400
Subject: Re: nfs root problem in linux-next
From: Mark Salter <msalter@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-next <linux-next@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Mon, 25 Jun 2012 23:17:43 -0400
In-Reply-To: <1340666049.4362.9.camel@lade.trondhjem.org>
References: <1340656006.20557.30.camel@deneb.redhat.com>
	 <1340666049.4362.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
Message-ID: <1340680664.20557.38.camel@deneb.redhat.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-06-25 at 23:14 +0000, Myklebust, Trond wrote:
> On Mon, 2012-06-25 at 16:26 -0400, Mark Salter wrote:
> > As of Friday's linux-next I've been unable to successfully boot using an
> > nfs root with a c6x board. I bisected it to this patch:
> > 
> >   commit cc3b296fd9a01c9e654bcb9373af70dd6e32fb24
> >   Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> >   Date:   Thu Jun 21 14:53:10 2012 -0400
> > 
> >       SUNRPC: Clean up xdr_read_pages and xdr_enter_page
> > 
> > I placed "good-boot" and "bad-boot" packet capture files at:
> > 
> >   http://people.redhat.com/~msalter/linux-next/
> > 
> > The only difference in the kernels used is the above patch. The
> > bad-boot mounted the nfs root but was unable to find the init
> > file which caused a panic. The nfsroot= parameter uses v3,tcp
> > flags and the server side is running rhel6.
> > 
> > I'm not at all familiar with the nfs code, but can help with
> > testing or providing any addtional info needed.
> 
> Hi Mark,
> 
> So you are saying that reverting that patch alone suffices to fix the
> problem that you are seeing?

Yes. If I check out a tree at commit cc3b296fd9a, the resulting kernel
does not boot (it panics that it cannot find init). If I check out a
tree at  cc3b296fd9a~1, it boots the nfs root successfully.

...
> I'll have a look to see if I can find out what is the problem. The only
> significant change that patch should be introducing would be the use of
> xdr_stream_pos().

Okay. I am happy to help with any testing if needed to help characterize
the problem better.

--Mark




