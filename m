From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [discuss] Re: 2.6.19-rc4: known unfixed regressions
	(v3)
Date: Wed, 08 Nov 2006 12:24:54 -0700
Message-ID: <m1r6wd3fnd.fsf@ebiederm.dsl.xmission.com>
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
   Ernst Herzberg <earny@net4u.de>, Aaron Durbin <adurbin@google.com>,
   Alex Romosan <romosan@sycorax.lbl.gov>, openib-general@openib.org,
   Andi Kleen <ak@suse.de>, linux-ide@vger.kernel.org,
   oprofile-list@lists.sourceforge.net, Jens Axboe <jens.axboe@oracle.com>,
   Adrian Bunk <bunk@stusta.de>, linux-pci@atrey.karlin.mff.cuni.cz,
   Elimar Riesebieter <riesebie@lxtec.de>, discuss@x86-64.org,
   linux-pm@osdl.org, Komuro <komurojun-mbn@nifty.com>,
   Jeff Chua <jeff.chua.linux@gmail.com>,
   Tim Chen <tim.c.chen@linux.intel.com>, phil.el@wanadoo.fr, gregkh@suse.de,
   neilb@cse.unsw.edu.au,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-acpi@vger.kernel.org, mingo@redhat.com, nfs@lists.sourceforge.net,
   cpufreq@lists.linux.o
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611081048330.3667@g5.osdl.org> (Linus Torvalds's
	message of "Wed, 8 Nov 2006 10:52:05 -0800 (PST)")
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

Linus Torvalds <torvalds@osdl.org> writes:

> On Wed, 8 Nov 2006, Eric W. Biederman wrote:
>> =

>> The implementations I have seen, I believe have all been on bridges and
>> the maximum size is actually generated from the bus number below the bri=
dge.
>
> Hmm. It might be possible to first set up the MMCONFIG thing for the =

> minimum range, then read the bus numbers from the host bridge on that bus=
, =

> and then expand the mmconfig range if necessary.
>
> Because pretty much ANYTHING is better than trusting the BIOS tables.
>
> That said, I'd really be a _lot_ more confident about it if we were to be =

> able to read the values from the hardware itself some way. There's =

> obviously a chicken-and-egg issue on mmcfg configuration, but it's one =

> that the BIOS startup code also has, so I assume that there is a solution =

> to that somewhere.

cfc and cf8 still work on x86.  So you can start with the old path
and then when you know mmconfig works you can upgrade.

In fact mmconfig doesn't necessary allow access to the entire pci domain.
On AMD systems currently you will get all of the subordinate busses but
the cpus themselves will not show up in the mmconfig space.

So we should have the infrastructure to only use mmconfig for some set
of busses.  If that interface is well described we can probably
bootstrap sanely, only enabling what we know exists and like wise
only reserving what we know is used.

For chipsets I know that there is quite a bit of information publicly
available.  For intel chipsets I believe those are registers they
make available in their public docs.  For things like the Nvidia
chipset the knowledge should be in the publicly available linuxbios
code base.

Hopefully that is enough of a pointer to get people going.  I might
have enough time to write the patch but I don't have enough time to
maintain it until mmconfig becomes boring.

Eric
