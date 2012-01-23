Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39052 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754548Ab2AWW1t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jan 2012 17:27:49 -0500
Date: Mon, 23 Jan 2012 17:27:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: Tigran Mkrtchyan <kofemann@googlemail.com>, linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v7 00/10] handle curruent stateid
Message-ID: <20120123222747.GD1452@fieldses.org>
References: <1327257968-14522-1-git-send-email-tigran.mkrtchyan@desy.de>
 <20120123211247.GA1452@fieldses.org>
 <CAGue13pu8=sSrf71KxgkP-GhpM4nv0yF5LfGr29T_Lp4Oj27cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAGue13pu8=sSrf71KxgkP-GhpM4nv0yF5LfGr29T_Lp4Oj27cw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 23, 2012 at 11:23:50PM +0100, Tigran Mkrtchyan wrote:
> On Mon, Jan 23, 2012 at 10:12 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Sun, Jan 22, 2012 at 07:45:59PM +0100, Tigran Mkrtchyan wrote:
> >> From: Tigran Mkrtchyan <kofemann@gmail.com>
> >>
> >> The same as v6, expect that the last patch changes current_stateid
> >> in compoind from reference to a value. As patches have to be squashed
> >> anyway
> >
> > Why?
> 
> for me none of them makes sense alone. But, of course, you have your own rules.

I think it's a little easier to read them as they are.  As long as it
compiles, and doesn't oops, at each step of the way, we're fine.

(OK, so it's buggy to support current stateid for some of these
operations but not all of them--but it was also buggy not to support
current stateid at all, so we're not making things any worse along the
way....)

> 
> >
> > If it's really only possible as a single big patch I'd actually rather
> > have it submitted that way....
> >
> >> this aproach is simple that re-write all.
> >
> > Fine, but #10 doesn't seem to have made it to my mailbox or to the list?
> 
> Ha! turned out that 000*.patch does not include 0010-X.patch :-D

Ah-hah!  Thanks.

--b.
