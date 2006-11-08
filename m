From: "Aaron Durbin" <adurbin@google.com>
Subject: Re: [discuss] Re: 2.6.19-rc4: known unfixed regressions
	(v3)
Date: Wed, 8 Nov 2006 11:10:13 -0800
Message-ID: <8f95bb250611081110x4260f95di6620e9ba7a00e58f@mail.gmail.com>
References: <Pine.LNX.4.64.0611080056480.12828@silvia.corp.fedex.com>
	<20061107171143.GU27140@parisc-linux.org>
	<200611080839.46670.ak@suse.de>
	<20061108122237.GF27140@parisc-linux.org>
	<Pine.LNX.4.64.0611080803280.3667@g5.osdl.org>
	<m1d57x4z58.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0611081048330.3667@g5.osdl.org>
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
To: "Linus Torvalds" <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611081048330.3667@g5.osdl.org>
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

On 11/8/06, Linus Torvalds <torvalds@osdl.org> wrote:
>
>
> On Wed, 8 Nov 2006, Eric W. Biederman wrote:
> >
> > The implementations I have seen, I believe have all been on bridges and
> > the maximum size is actually generated from the bus number below the br=
idge.
>
> Hmm. It might be possible to first set up the MMCONFIG thing for the
> minimum range, then read the bus numbers from the host bridge on that bus,
> and then expand the mmconfig range if necessary.
>
> Because pretty much ANYTHING is better than trusting the BIOS tables.
>
> That said, I'd really be a _lot_ more confident about it if we were to be
> able to read the values from the hardware itself some way. There's
> obviously a chicken-and-egg issue on mmcfg configuration, but it's one
> that the BIOS startup code also has, so I assume that there is a solution
> to that somewhere.
>

I agree that the orignal patch was stupid in relying on the MCFG table repo=
rted
in ACPI, however, like you said, without the actual knowledge of the MCFG
region being pulled out of the hardware even the e820 check is not valid. I=
t is
close, but not entirely correct. For instance, if the MCFG region is being
reported in ACPI land as 256 buses and the e820 has a reservation at the
MCFG base address of 18MB that does not necessarily mean the MCFG region al=
lows
for PCI config access on 18 buses. It could be that it only allows 16 buses=
 w/
another piece of hardware on that last 2MB.

So what is the proper scenario? One needs to know the actual upper limit of
MCFG region. Otherwise when detecting unreachable devices one could be poki=
ng
something else in the process of trying to discover these unreachable devic=
es.
I am open to ideas and am willing to rework some of the code, but I do like=
 the
idea of having the region being reported in the resource table.

-Aaron
