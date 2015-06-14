Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailsec119.isp.belgacom.be ([195.238.20.115]:29075 "EHLO
	mailsec119.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750867AbbFNFXM convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Jun 2015 01:23:12 -0400
Date: Sun, 14 Jun 2015 07:23:10 +0200 (CEST)
From: Fabian Frederick <fabf@skynet.be>
Reply-To: Fabian Frederick <fabf@skynet.be>
To: Joe Perches <joe@perches.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Julia Lawall <Julia.Lawall@lip6.fr>,
        Anna Schumaker <anna.schumaker@netapp.com>
Message-ID: <1083240637.131521.1434259390284.open-xchange@webmail.nmp.proximus.be>
In-Reply-To: <1434129477.2972.38.camel@perches.com>
References: <1434128330-10253-1-git-send-email-fabf@skynet.be> <1434129477.2972.38.camel@perches.com>
Subject: Re: [PATCH 1/1 linux-next] pnfs/flexfiles: use swap() in
 ff_layout_sort_mirrors()
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On 12 June 2015 at 19:17 Joe Perches <joe@perches.com> wrote:
>
>
> On Fri, 2015-06-12 at 18:58 +0200, Fabian Frederick wrote:
> > Use kernel.h macro definition.
>
> A lot of these conversions seem to be for bubble sorts.
> Maybe it'd be useful to add a generic one somewhere.

Of course but those swap() conversions already do some smooth cleanup.
btw it will be easier to find sort occurences and replace them if necessary.

Regards,
Fabian
>
> > diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c
> > b/fs/nfs/flexfilelayout/flexfilelayout.c
> []
> > @@ -182,17 +182,14 @@ static void _ff_layout_free_lseg(struct
> > nfs4_ff_layout_segment *fls)
> > 
> >  static void ff_layout_sort_mirrors(struct nfs4_ff_layout_segment *fls)
> >  {
> > -   struct nfs4_ff_layout_mirror *tmp;
> >     int i, j;
> > 
> >     for (i = 0; i < fls->mirror_array_cnt - 1; i++) {
> >             for (j = i + 1; j < fls->mirror_array_cnt; j++)
> >                     if (fls->mirror_array[i]->efficiency <
> > -                       fls->mirror_array[j]->efficiency) {
> > -                           tmp = fls->mirror_array[i];
> > -                           fls->mirror_array[i] = fls->mirror_array[j];
> > -                           fls->mirror_array[j] = tmp;
> > -                   }
> > +                       fls->mirror_array[j]->efficiency)
> > +                           swap(fls->mirror_array[i],
> > +                                fls->mirror_array[j]);
> >     }
> >  }
> > 
>
>
>
