From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/4] 2.6.23-rc5: known regressions
Date: Sat, 8 Sep 2007 00:52:33 +0200
Message-ID: <6bffcb0e0709071552j44d8cdffx813bfa614012dbd@mail.gmail.com>
References: <46DBD982.3080102@googlemail.com> <46DBDD8B.7040706@googlemail.com>
	 <46DBE660.9020309@zytor.com>
	 <20070903054602.68ddd468.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "H. Peter Anvin" <hpa@zytor.com>, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, lists4me@web.de,
	jeff.chua.linux@gmail.com, adaplas@gmail.com, lenb@kernel.org,
	dth@dth.net, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net, Trond.Myklebust@netapp.com,
	andrew@digital-domain.net, peter.kovar@gmail.com
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070903054602.68ddd468.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

On 03/09/2007, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Mon, 03 Sep 2007 11:48:00 +0100 "H. Peter Anvin" <hpa@zytor.com> wrote:
> > Michal Piotrowski wrote:
> > >
> > > Unclassified
> > >
> > > Subject         : console is messed up after resume from s2ram or switching to console from X
> > > References      : http://lkml.org/lkml/2007/8/4/6
> > > Last known good : ?
> > > Submitter       : Jeff Chua <jeff.chua.linux@gmail.com>
> > > Caused-By       : ?
> > > Handled-By      : H. Peter Anvin <hpa@zytor.com>
> > >                   Antonino A. Daplas <adaplas@gmail.com>
> > > Workaround      : "s2ram --force --acpi_sleep 1 --vbe_mode"
> > > Status          : problem is being debugged
> > >
> >
> > I'm inclined to write this one off as general STR weirdness.
>
> Both suspend-to-ram and suspend-to-disk are broken on this Vaio.  Running
> 2.6.23-rc4.
>
>
> suspend-to-RAM:
>
> a) sometimes hangs during suspend
>
> b) frequently hangs during resume
>
> c) occasionally acts weird after resume.  system requires repeated
>    keypresses to make forward progress.

could be related with

Subject         : cpu hotplug support broken in 2.6.23-rc3/highres
timers break cpu hotplug in 2.6.23-rc5
References      : http://lkml.org/lkml/2007/8/27/58
                  http://lkml.org/lkml/2007/9/3/65
Last known good : ?
Submitter       : Pavel Machek <pavel@ucw.cz>
Caused-By       : ?
Handled-By      : ?
Status          : problem is being debugged

>
> d) on those occasions where resume-from-RAM _does_ work, it takes much
>    longer to resume than it used to.


Subject         : resume from ram much slower
References      : http://lkml.org/lkml/2007/8/10/275
Last known good : 2.6.23-rc1 ?
Submitter       : Arkadiusz Miskiewicz <arekm@maven.pl>
Caused-By       : ?
Handled-By      : Rafael J. Wysocki <rjw@sisk.pl>
Status          : problem is being debugged

?

>
> suspend-to-disk:
>
> a) always hangs when netconsole-over-e100 is enabled (might have been a
>    2.6.21->2.6.22 regression).
>
> b) usually hangs during suspend
>
>
> Apart from suspend-to-disk's a), all of the above are post-2.6.21
> regressions.
>
>
>

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
