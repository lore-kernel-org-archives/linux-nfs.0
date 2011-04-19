Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:40241 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278Ab1DSVRL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Apr 2011 17:17:11 -0400
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
        stable@kernel.org, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [105/105] nfsd4: fix oops on lock failure
References: <20110412143559.186613198@clark.kroah.org>
	<87pqokx6lr.fsf@devron.myhome.or.jp>
	<BANLkTimN6L80e_oiJ_uqbLde2Cdnw5p45Q@mail.gmail.com>
	<20110418153236.GC20935@pad.home.fieldses.org>
	<87ipubwnj3.fsf@devron.myhome.or.jp>
	<8762qbwnf1.fsf@devron.myhome.or.jp>
	<87zknnv7id.fsf@devron.myhome.or.jp>
	<87vcybgt6u.fsf@devron.myhome.or.jp>
	<87hb9uhcre.fsf@devron.myhome.or.jp>
	<20110419204349.GB8228@fieldses.org>
Date: Wed, 20 Apr 2011 06:17:03 +0900
In-Reply-To: <20110419204349.GB8228@fieldses.org> (J. Bruce Fields's message
	of "Tue, 19 Apr 2011 16:43:49 -0400")
Message-ID: <87aafmgcvk.fsf@devron.myhome.or.jp>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Tue, Apr 19, 2011 at 05:21:57PM +0900, OGAWA Hirofumi wrote:
>> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:
>> 
>> >> I'll start test of this patch, and see what happens.
>> >
>> > OK. Although filp slabs are still slightly increasing (I'm not sure yet
>> > whether this is leak of filp on system). But watching before/after
>> > patch, the graph of filp slabs is clearly different.
>> >
>> > As far as I can say patches are fine.
>> 
>> slightly increasing was stopped at 2200-2300. filp leak seems to be fixed.
>
> Another thing to check is whether you can always unmount the exported
> filesystem on the server after running your test.  So something like:
>
> 	service nfs stop
> 	unmount /exports/fs
>
> should always succeed; if you get an inexplicable EBUSY on the final
> unmount then we likely still have a leak someplace.

It succeeded.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
