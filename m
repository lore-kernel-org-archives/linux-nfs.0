Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:57554 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab1DSIWF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Apr 2011 04:22:05 -0400
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <gregkh@suse.de>,
        linux-kernel@vger.kernel.org, stable@kernel.org,
        akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
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
Date: Tue, 19 Apr 2011 17:21:57 +0900
In-Reply-To: <87vcybgt6u.fsf@devron.myhome.or.jp> (OGAWA Hirofumi's message of
	"Tue, 19 Apr 2011 06:12:25 +0900")
Message-ID: <87hb9uhcre.fsf@devron.myhome.or.jp>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:

>> I'll start test of this patch, and see what happens.
>
> OK. Although filp slabs are still slightly increasing (I'm not sure yet
> whether this is leak of filp on system). But watching before/after
> patch, the graph of filp slabs is clearly different.
>
> As far as I can say patches are fine.

slightly increasing was stopped at 2200-2300. filp leak seems to be fixed.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
