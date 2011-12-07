Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:61441 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638Ab1LGRRS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2011 12:17:18 -0500
Received: by vcbfk14 with SMTP id fk14so630241vcb.19
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2011 09:17:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111207171133.GD20079@fieldses.org>
References: <1323207847-19118-1-git-send-email-tigran.mkrtchyan@desy.de>
	<20111206230823.GH12640@fieldses.org>
	<4EDF677C.7030209@tonian.com>
	<20111207171133.GD20079@fieldses.org>
Date: Wed, 7 Dec 2011 18:17:17 +0100
Message-ID: <CAFpJMDqaba1Zznb8+46earbqb9Kms+8Dt2oQ-fKcpFr1_bKYqA@mail.gmail.com>
Subject: Re: [PATCH] nfsd41: handle current stateid in open and close
From: Tiramisu Mokka <kofemann@googlemail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Benny Halevy <bhalevy@tonian.com>, linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <kofemann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 7, 2011 at 18:11, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Dec 07, 2011 at 03:17:48PM +0200, Benny Halevy wrote:
>> On 2011-12-07 01:08, J. Bruce Fields wrote:
>> > It's a little verbose, but yes it does nicely collect the current
>> > stateid getting/setting into one place.  Benny, is the more or less what
>> > you were thinking of?
>>
>> Yes it is, though I also liked your direction of just using the current
>> stateid for xdr decoding and encoding.
>
> I'd still have a slight preference for doing it that way, just because
> it would take fewer lines of code--but I can live with this too, so I'll
> leave the choice to Tigran's excellent taste....

I will prefer current approach as it makes less disaster than
propagating the knowledge about stateid handling deep into xdr layer.

Tigran.

>
>> { ~0, { { ~0, ~0 }, ~0 } } is ugly but compact :)
>>
>> And the following may be an overkill...
>> {
>>       .si_generation = ~0,
>>       .si_opaque = {
>>               .so_clid = {
>>                       .cl_boot = ~0,
>>                       .cl_id = ~0,
>>               },
>>               .so_id = ~0
>>       }
>> };
>
> Reminding myself of http://tools.ietf.org/html/rfc5661#section-8.2.3...
> "Stateid values whose "other" field is either all zeros or all ones are
> reserved."
>
> Maybe:
>
> #define all_ones   {{~0,~0 },~0}
> #define all_zeroes {{ 0, 0 }, 0}
> const stateid_t one_stateid = {
>        .si_generation = ~0,
>        .si_opaque = all_ones
> };
> const stateid_t current_stateid = {
>        .si_generation = 1,
>        .si_opaque = all_zeroes
> };
> ...
>
> Or you could ditch the all_zeroes; it's just there for some kind of
> symmetry.
>
> --b.
