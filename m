From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2/4] 2.6.23-rc5: known regressions
Date: Mon, 3 Sep 2007 05:46:02 -0700
Message-ID: <20070903054602.68ddd468.akpm@linux-foundation.org>
References: <46DBD982.3080102@googlemail.com>
	<46DBDD8B.7040706@googlemail.com>
	<46DBE660.9020309@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: michal.k.k.piotrowski@gmail.com, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, lists4me@web.de,
	jeff.chua.linux@gmail.com, adaplas@gmail.com, lenb@kernel.org,
	dth@dth.net, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net, Trond.Myklebust@netapp.com,
	andrew@digital-domain.net, peter.kovar@gmail.com
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <46DBE660.9020309@zytor.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

> On Mon, 03 Sep 2007 11:48:00 +0100 "H. Peter Anvin" <hpa@zytor.com> wrote:
> Michal Piotrowski wrote:
> > 
> > Unclassified
> > 
> > Subject         : console is messed up after resume from s2ram or switching to console from X
> > References      : http://lkml.org/lkml/2007/8/4/6
> > Last known good : ?
> > Submitter       : Jeff Chua <jeff.chua.linux@gmail.com>
> > Caused-By       : ?
> > Handled-By      : H. Peter Anvin <hpa@zytor.com>
> >                   Antonino A. Daplas <adaplas@gmail.com>
> > Workaround      : "s2ram --force --acpi_sleep 1 --vbe_mode"
> > Status          : problem is being debugged
> > 
> 
> I'm inclined to write this one off as general STR weirdness.

Both suspend-to-ram and suspend-to-disk are broken on this Vaio.  Running
2.6.23-rc4.


suspend-to-RAM:

a) sometimes hangs during suspend

b) frequently hangs during resume

c) occasionally acts weird after resume.  system requires repeated
   keypresses to make forward progress.

d) on those occasions where resume-from-RAM _does_ work, it takes much
   longer to resume than it used to.

suspend-to-disk:

a) always hangs when netconsole-over-e100 is enabled (might have been a
   2.6.21->2.6.22 regression).

b) usually hangs during suspend


Apart from suspend-to-disk's a), all of the above are post-2.6.21
regressions.


