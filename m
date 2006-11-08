From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [discuss] Re: 2.6.19-rc4: known unfixed regressions
	(v3)
Date: Wed, 8 Nov 2006 11:25:40 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611081119160.22714@g5.osdl.org>
References: <Pine.LNX.4.64.0611080056480.12828@silvia.corp.fedex.com>
	<20061107171143.GU27140@parisc-linux.org>
	<200611080839.46670.ak@suse.de>
	<20061108122237.GF27140@parisc-linux.org>
	<Pine.LNX.4.64.0611080803280.3667@g5.osdl.org>
	<m1d57x4z58.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0611081048330.3667@g5.osdl.org>
	<8f95bb250611081110x4260f95di6620e9ba7a00e58f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@osdl.org>, len.brown@intel.com,
   Thierry Vignaud <tvignaud@mandriva.com>, Matthew Wilcox <matthew@wil.cx>,
   Ernst Herzberg <earny@net4u.de>, Christian <christiand59@web.de>,
   Alex Romosan <romosan@sycorax.lbl.gov>, openib-general@openib.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-ide@vger.kernel.org, oprofile-list@lists.sourceforge.net,
   Jens Axboe <jens.axboe@oracle.com>, linux-pci@atrey.karlin.mff.cuni.cz,
   Elimar Riesebieter <riesebie@lxtec.de>, discuss@x86-64.org,
   linux-pm@osdl.org, Komuro <komurojun-mbn@nifty.com>,
   Jeff Chua <jeff.chua.linux@gmail.com>,
   Tim Chen <tim.c.chen@linux.intel.com>, phil.el@wanadoo.fr, gregkh@suse.de,
   neilb@cse.unsw.edu.au, Adrian Bunk <bunk@stusta.de>,
   linux-acpi@vger.kernel.org, mingo@redhat.com, nfs@lists.sourceforge.net,
   "Eric W. Biederman" <ebiederm@xmission.com>, cpufre
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Aaron Durbin <adurbin@google.com>
In-Reply-To: <8f95bb250611081110x4260f95di6620e9ba7a00e58f@mail.gmail.com>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-ID: <nfs.lists.sourceforge.net>



On Wed, 8 Nov 2006, Aaron Durbin wrote:
>
> For instance, if the MCFG region is being reported in ACPI land as 256 =

> buses and the e820 has a reservation at the MCFG base address of 18MB =

> that does not necessarily mean the MCFG region allows for PCI config =

> access on 18 buses. It could be that it only allows 16 buses w/ another =

> piece of hardware on that last 2MB.

Oh, I agree. You'd _hope_ that the BIOS reports that as a separate region, =

and we could use that as a hint, but it's never going to be fool-proof. =


It's just much much better to try to figure out what the hardware itself =

thinks it is doing, rather than relying on a firmware engineer filling out =

the table to match what he _thinks_ the hardware is doing (or, more =

accurately, randomly scribbling values until Windows boots, at which point =

it's not his problem any more, and people ship the crap).

Some misguided people used to think that we shouldn't do our own PCI =

probing, but use ACPI instead. This is the same thing, except on a smaller =

scale. MAYBE the scale ends up being so small that we can figure out some =

reliable way without actually asking the hardware itself, but I kind of =

doubt it. Especially judging by the current situation.

> So what is the proper scenario? One needs to know the actual upper limit =
of
> MCFG region. Otherwise when detecting unreachable devices one could be po=
king
> something else in the process of trying to discover these unreachable dev=
ices.
> I am open to ideas and am willing to rework some of the code, but I do li=
ke
> the idea of having the region being reported in the resource table.

Absolutely. I'd _love_ to have the region reported in the resource table. =

It's just that right now it doesn't seem practical, since the downsides =

are bigger than the upsides (and the upsides aren't _that_ big, since we =

require the thing to be marked reserved in the e820 tables anyway, so the =

resource tables do know about it, about as well as they currently can).

In the absense of a way to actually ask the hardware, we could perhaps =

modify the thing so that it does request the regions in the resource =

table, but _only_ if the e820 entries aren't there (ie the "config type 1 =

didn't even work" case).

Alternatively, we might choose to request just the known smallest region, =

because that should be relatively "safer". It's better than not reporting =

the regions at all, and while it's not perfect, it at least shouldn't have =

huge potential downsides from getting the size totally wrong...

Hmm?

		Linus
