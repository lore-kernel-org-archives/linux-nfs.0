From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [105/105] nfsd4: fix oops on lock failure
Date: Tue, 19 Apr 2011 17:33:31 -0400
Message-ID: <20110419213331.GA9998@fieldses.org>
References: <87pqokx6lr.fsf@devron.myhome.or.jp>
 <BANLkTimN6L80e_oiJ_uqbLde2Cdnw5p45Q@mail.gmail.com>
 <20110418153236.GC20935@pad.home.fieldses.org>
 <87ipubwnj3.fsf@devron.myhome.or.jp>
 <8762qbwnf1.fsf@devron.myhome.or.jp>
 <87zknnv7id.fsf@devron.myhome.or.jp>
 <87vcybgt6u.fsf@devron.myhome.or.jp>
 <87hb9uhcre.fsf@devron.myhome.or.jp>
 <20110419204349.GB8228@fieldses.org>
 <87aafmgcvk.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	stable@kernel.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, Neil Brown <neilb@suse.de>,
	linux-nfs@vger.kernel.org
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48581 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753701Ab1DSVdm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Apr 2011 17:33:42 -0400
In-Reply-To: <87aafmgcvk.fsf-x/W9pkDDSe1TgC2z9Sl/nXf5DAMn2ifp@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 20, 2011 at 06:17:03AM +0900, OGAWA Hirofumi wrote:
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> 
> > On Tue, Apr 19, 2011 at 05:21:57PM +0900, OGAWA Hirofumi wrote:
> >> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:
> >> 
> >> >> I'll start test of this patch, and see what happens.
> >> >
> >> > OK. Although filp slabs are still slightly increasing (I'm not sure yet
> >> > whether this is leak of filp on system). But watching before/after
> >> > patch, the graph of filp slabs is clearly different.
> >> >
> >> > As far as I can say patches are fine.
> >> 
> >> slightly increasing was stopped at 2200-2300. filp leak seems to be fixed.
> >
> > Another thing to check is whether you can always unmount the exported
> > filesystem on the server after running your test.  So something like:
> >
> > 	service nfs stop
> > 	unmount /exports/fs
> >
> > should always succeed; if you get an inexplicable EBUSY on the final
> > unmount then we likely still have a leak someplace.
> 
> It succeeded.

Good, thanks.--b.
