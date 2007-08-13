From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: [1/2] 2.6.23-rc3: known regressions with patches
Date: Mon, 13 Aug 2007 22:24:52 +0200
Message-ID: <6bffcb0e0708131324x29211ef5sd5154d44f0c2e79f@mail.gmail.com>
References: <46C09C1A.7050706@googlemail.com>
	 <20070813184204.GA6071@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Gabriel C" <nix.or.die@googlemail.com>,
	"Stefan Richter" <stefanr@s5r6.in-berlin.de>,
	"Jan Engelhardt" <jengelh@linux01.gwdg.de>,
	"Satyam Sharma" <satyam.sharma@gmail.com>,
	"Vitaly Bordug" <vitb@kernel.crashing.org>,
	"Dan Merillat" <dan.merillat@gmail.com>,
	"Paolo Ornati" <ornati@fastwebnet.it>,
	"Rusty Russell" <rusty@rustcorp.com.au>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	"Jeff Garzik" <jeff@garzik.org>,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070813184204.GA6071@one.firstfloor.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On 13/08/07, Andi Kleen <andi@firstfloor.org> wrote:
> > Unclassified
> >
> > Subject         : reset during bootup - 2.6.23-rc2 (git d23cf676)
>
> This is already fixed in mainline

commit b8d3f2448b8f4ba24f301e23585547ba1acc1f04

>
> There is a real regression with failing builds on some old binutils on
> x86-64 know, but I don't know how to fix it.

Did you mean this?

Subject         : /usr/bin/ld: section .text [ffffffffff700500 ->
ffffffffff7007e3] overlaps section .gnu.version_d [ffffffffff7004d8 ->
ffffffffff70050f]
References      : http://lkml.org/lkml/2007/7/22/239
Last known good : ?
Submitter       : Andre Noll <maan@systemlinux.org>
Caused-By       : ?
Handled-By      : Andi Kleen <ak@suse.de>
Status          : problem is being debugged

>
> -Andi
>

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
