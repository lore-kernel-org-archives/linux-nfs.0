Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52969 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755468Ab1LBPPP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Dec 2011 10:15:15 -0500
Date: Fri, 2 Dec 2011 10:15:12 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils and libnfsidmap
Message-ID: <20111202151512.GA14393@fieldses.org>
References: <CAGue13qasD7m+dj3PdA+p5jfJQU_Eq0r+Z9QqtvOSnadFmWJeg@mail.gmail.com>
 <20111123201345.GA1044@fieldses.org>
 <4ED39F2D.7050508@RedHat.com>
 <CAGue13qyZPwTF1erSPwj5iaiwOOq8NGdpedS0BeMZ3JCFSveYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAGue13qyZPwTF1erSPwj5iaiwOOq8NGdpedS0BeMZ3JCFSveYw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 02, 2011 at 03:41:21PM +0100, Tigran Mkrtchyan wrote:
> On Mon, Nov 28, 2011 at 3:48 PM, Steve Dickson <SteveD@redhat.com> wrote:
> > On 11/23/2011 03:13 PM, J. Bruce Fields wrote:
> >> On Wed, Nov 23, 2011 at 08:54:06PM +0100, Tigran Mkrtchyan wrote:
> >>> Hi All,
> >>>
> >>> today was tracing a bug in nfs-utils/libnfsidmap and after a log
> >>> debugging located it and
> >>> finally realized that it's already fixed by Steve Dickson (
> >>> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=d22ef3f525d71b565fcc688557273a6cabeeb71a
> >>> ). Nevertheless during
> >>> this procedure it turned out that there is quite some code duplicated
> >>> between nfs-utils and
> >>> libnfsidmap.
> >>>
> >>> Questions:
> >>>    a) why nfs-utils duplicates some part of libnfsidmap and still depends o it
> >>>    b) is there readon for code duplication? Licensing or so
> >>>    c) what ww need to do to get rid of duplication
> >>>
> >>> I expect the answer of 'c' will contain something like time and man power.
> >>> I am volunteering to to pend some time on it.
> >>
> >> I doubt there's any real reason for duplication.
> > Just curious as to what code we are talking about...
> 
> for example
>   nfs-utils/support/nfs/conffile.c  => libnfsidmap/cfg.c
>   nfs-utils/utils/idmapd/queue.h =>  libnfsidmap/queue.h
> 
> probably some other files as well.

OK.  I'm sure reasonable patches would be welcomed.

--b.
