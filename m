From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 5/5] nfsd41: replace page based DRC with buffer
	based DRC
Date: Mon, 31 Aug 2009 09:43:53 -0400
Message-ID: <89c397150908310643u460105a0re8fb2810d5919178@mail.gmail.com>
References: <1251389264-3009-1-git-send-email-andros@netapp.com>
	 <1251389264-3009-2-git-send-email-andros@netapp.com>
	 <1251389264-3009-3-git-send-email-andros@netapp.com>
	 <1251389264-3009-4-git-send-email-andros@netapp.com>
	 <1251389264-3009-5-git-send-email-andros@netapp.com>
	 <1251389264-3009-6-git-send-email-andros@netapp.com>
	 <20090828213323.GD2462@fieldses.org> <4A9B06FF.2030303@panasas.com>
	 <20090831130822.GB27432@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f188.google.com ([209.85.211.188]:59134 "EHLO
	mail-yw0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbZHaNnv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Aug 2009 09:43:51 -0400
Received: by ywh26 with SMTP id 26so6047642ywh.5
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2009 06:43:53 -0700 (PDT)
In-Reply-To: <20090831130822.GB27432@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK - Thanks for the review. New patches to follow..

-->Andy

On Mon, Aug 31, 2009 at 9:08 AM, J. Bruce Fields<bfields@fieldses.org> =
wrote:
> On Mon, Aug 31, 2009 at 02:10:55AM +0300, Benny Halevy wrote:
>> On Aug. 29, 2009, 0:33 +0300, "J. Bruce Fields" <bfields-uC3wQj2KruMpug/h7KTFAQ@public.gmane.org=
g> wrote:
>> > I think this is OK for now, but maybe stick something like:
>> >
>> > =A0 =A0 BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struct nf=
sd4_slot)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 + sizeof(struct nfsd4_sess=
ion) > PAGE_SIZE);
>> >
>> > in state.h just to warn anyone who wants to blindly bump up
>>
>> I think that the BUILD_BUG_ON should be placed in a function so
>> it gets to compile,
>
> Whoops, thanks--I hadn't noticed that.
>
>> so it'd better be defined here and not in state.h
>> (where it also is in the right context)
>
> Sounds fine.--b.
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
