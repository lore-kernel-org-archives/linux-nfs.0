Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f42.google.com ([74.125.82.42]:52327 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836Ab1LHQJP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 11:09:15 -0500
Received: by wgbds13 with SMTP id ds13so1551813wgb.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Dec 2011 08:09:13 -0800 (PST)
Message-ID: <4EE0E123.20401@tonian.com>
Date: Thu, 08 Dec 2011 18:09:07 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Tigran Mkrtchyan <kofemann@googlemail.com>, linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATCH] nfsd41: handle current stateid in open and close
References: <1323207847-19118-1-git-send-email-tigran.mkrtchyan@desy.de> <20111206230823.GH12640@fieldses.org> <4EDF677C.7030209@tonian.com> <20111207171133.GD20079@fieldses.org>
In-Reply-To: <20111207171133.GD20079@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-07 19:11, J. Bruce Fields wrote:
> On Wed, Dec 07, 2011 at 03:17:48PM +0200, Benny Halevy wrote:
>> On 2011-12-07 01:08, J. Bruce Fields wrote:
>>> It's a little verbose, but yes it does nicely collect the current
>>> stateid getting/setting into one place.  Benny, is the more or less what
>>> you were thinking of?
>>
>> Yes it is, though I also liked your direction of just using the current
>> stateid for xdr decoding and encoding.
> 
> I'd still have a slight preference for doing it that way, just because
> it would take fewer lines of code--but I can live with this too, so I'll
> leave the choice to Tigran's excellent taste....
> 
>> { ~0, { { ~0, ~0 }, ~0 } } is ugly but compact :)
>>
>> And the following may be an overkill...
>> {
>> 	.si_generation = ~0,
>> 	.si_opaque = {
>> 		.so_clid = {
>> 			.cl_boot = ~0,
>> 			.cl_id = ~0,
>> 		},
>> 		.so_id = ~0
>> 	}
>> };
> 
> Reminding myself of http://tools.ietf.org/html/rfc5661#section-8.2.3...
> "Stateid values whose "other" field is either all zeros or all ones are
> reserved."
> 
> Maybe:
> 
> #define all_ones   {{~0,~0 },~0}
> #define all_zeroes {{ 0, 0 }, 0}
> const stateid_t one_stateid = {
> 	.si_generation = ~0,
> 	.si_opaque = all_ones
> };

That looks like a good compromise to me.

> const stateid_t current_stateid = {
> 	.si_generation = 1,
> 	.si_opaque = all_zeroes
> };
> ...
> 
> Or you could ditch the all_zeroes; it's just there for some kind of
> symmetry.

Yeah, static initialization to zero is guaranteed.

Benny

> 
> --b.
