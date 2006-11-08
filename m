From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [discuss] Re: 2.6.19-rc4: known unfixed regressions
	(v3)
Date: Wed, 8 Nov 2006 10:52:05 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611081048330.3667@g5.osdl.org>
References: <Pine.LNX.4.64.0611080056480.12828@silvia.corp.fedex.com>
	<20061107171143.GU27140@parisc-linux.org>
	<200611080839.46670.ak@suse.de>
	<20061108122237.GF27140@parisc-linux.org>
	<Pine.LNX.4.64.0611080803280.3667@g5.osdl.org>
	<m1d57x4z58.fsf@ebiederm.dsl.xmission.com>
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
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1d57x4z58.fsf@ebiederm.dsl.xmission.com>
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



On Wed, 8 Nov 2006, Eric W. Biederman wrote:
> =

> The implementations I have seen, I believe have all been on bridges and
> the maximum size is actually generated from the bus number below the brid=
ge.

Hmm. It might be possible to first set up the MMCONFIG thing for the =

minimum range, then read the bus numbers from the host bridge on that bus, =

and then expand the mmconfig range if necessary.

Because pretty much ANYTHING is better than trusting the BIOS tables.

That said, I'd really be a _lot_ more confident about it if we were to be =

able to read the values from the hardware itself some way. There's =

obviously a chicken-and-egg issue on mmcfg configuration, but it's one =

that the BIOS startup code also has, so I assume that there is a solution =

to that somewhere.

		Linus
