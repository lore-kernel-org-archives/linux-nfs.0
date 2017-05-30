Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gardel.0pointer.net ([85.214.157.71]:45742 "EHLO
        gardel.0pointer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbdE3MqB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 08:46:01 -0400
Date: Tue, 30 May 2017 14:45:58 +0200
From: Lennart Poettering <lennart@poettering.net>
To: Michael Biebl <mbiebl@gmail.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org,
        systemd-devel@freedesktop.org
Subject: Re: [systemd-devel] [PATCH] nfs.man: document incompatibility
 between "bg" option and systemd.
Message-ID: <20170530124558.GB19096@gardel-login>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <CAGWsdOh5Sy-=8uv1aLUsCs+Co_QHgrkbUOJ0fXkb=Xskcez6JQ@mail.gmail.com>
 <87inkig1vw.fsf@notabene.neil.brown.name>
 <CAGWsdOjd+HDity=qO0Rfk9RZ6bujwcXkR3MeZdN7ubroBPJ0sA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAGWsdOjd+HDity=qO0Rfk9RZ6bujwcXkR3MeZdN7ubroBPJ0sA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 30.05.17 11:15, Michael Biebl (mbiebl@gmail.com) wrote:

> 2017-05-30 10:55 GMT+02:00 NeilBrown <neilb@suse.com>:
> > On Tue, May 30 2017, Michael Biebl wrote:
> >
> >> 2017-05-30 0:19 GMT+02:00 NeilBrown <neilb@suse.com>:
> >>
> >>> +.B bg
> >>> +option is not supported, and may be stripped from the option list.
> >>
> >> Either systemd is updated to actually strip the bg option or not. The
> >> documentation should reflect that.
> >> I don't think we should be vague about this, as it would only be confusing.
> >
> > It depends on which version of systemd is in use.
> > Even if/when systemd is updated to strip the 'bg', it would not
> > be correct to say "and will be stripped..." as that isn't true for all
> > versions.
> > We could spell it out "and may be stripped from the option list,
> > depending on which version of systemd is installed", but I'm not sure
> > that really helps...
> >  "... and some versions of systemd will strip 'bg' from the option list"
> >  ??
> 
> So far, no version of systemd strips bg from the option list.
> If in version X systemd actually starts stripping bg, we should
> explicitly mention that version in the man page imho.

I figure it's up to the NFS folks to decide on this, but if I were
them I would not mention any version numbers. That just gets out of
date. Instead, document the new behaviour and indicate in the README
file that the documentation assumes systemd with a certain version is
used, and then let the packers figure out the rest, i.e. if they want
to place some kind of weak package version dependency or not.

Lennart

-- 
Lennart Poettering, Red Hat
