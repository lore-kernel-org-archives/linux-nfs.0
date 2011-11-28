Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39058 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753029Ab1K1RGr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Nov 2011 12:06:47 -0500
Date: Mon, 28 Nov 2011 12:06:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils and libnfsidmap
Message-ID: <20111128170644.GA3105@fieldses.org>
References: <CAGue13qasD7m+dj3PdA+p5jfJQU_Eq0r+Z9QqtvOSnadFmWJeg@mail.gmail.com>
 <20111123201345.GA1044@fieldses.org>
 <4ED39F2D.7050508@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4ED39F2D.7050508@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 28, 2011 at 09:48:13AM -0500, Steve Dickson wrote:
> On 11/23/2011 03:13 PM, J. Bruce Fields wrote:
> > On Wed, Nov 23, 2011 at 08:54:06PM +0100, Tigran Mkrtchyan wrote:
> >> Hi All,
> >>
> >> today was tracing a bug in nfs-utils/libnfsidmap and after a log
> >> debugging located it and
> >> finally realized that it's already fixed by Steve Dickson (
> >> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=d22ef3f525d71b565fcc688557273a6cabeeb71a
> >> ). Nevertheless during
> >> this procedure it turned out that there is quite some code duplicated
> >> between nfs-utils and
> >> libnfsidmap.
> >>
> >> Questions:
> >>    a) why nfs-utils duplicates some part of libnfsidmap and still depends o it
> >>    b) is there readon for code duplication? Licensing or so
> >>    c) what ww need to do to get rid of duplication
> >>
> >> I expect the answer of 'c' will contain something like time and man power.
> >> I am volunteering to to pend some time on it.
> > 
> > I doubt there's any real reason for duplication.
> Just curious as to what code we are talking about...

Yes, maybe Tigran can demonstrate with a patch.

> > Probably libnfsidmap should be part of nfs-utils, actually.
> I guess we could roll the libnfsidmap git tree into the nfs-utils
> tree... if that make senses... It probably would simply things.. 

OK.

> > And maybe we don't need it at all--the original reason to split out
> > libnfsidmap was to share the code with libacl, so the posix getfacl
> > command could do v4->posix acl mapping, but those patches never made it
> > upstream.
> So you don't think this will every happen?

I don't know.  If it's easy to keep it as a separate library, then maybe
we should just in case.  But for now it seems unlikely.

--b.
