From: Andi Kleen <ak@suse.de>
Subject: Re: [discuss] Re: 2.6.19-rc4: known unfixed regressions
	(v3)
Date: Fri, 10 Nov 2006 07:52:54 +0100
Message-ID: <200611100752.55517.ak@suse.de>
References: <Pine.LNX.4.64.0611080056480.12828@silvia.corp.fedex.com>
	<Pine.LNX.4.64.0611081048330.3667@g5.osdl.org>
	<m1r6wd3fnd.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@osdl.org>, len.brown@intel.com,
   Thierry Vignaud <tvignaud@mandriva.com>, Matthew Wilcox <matthew@wil.cx>,
   Ernst Herzberg <earny@net4u.de>, Aaron Durbin <adurbin@google.com>,
   Alex Romosan <romosan@sycorax.lbl.gov>, openib-general@openib.org,
   neilb@cse.unsw.edu.au, linux-ide@vger.kernel.org,
   Linus Torvalds <torvalds@osdl.org>, oprofile-list@lists.sourceforge.net,
   Jens Axboe <jens.axboe@oracle.com>, linux-pci@atrey.karlin.mff.cuni.cz,
   Elimar Riesebieter <riesebie@lxtec.de>, linux-pm@osdl.org,
   Komuro <komurojun-mbn@nifty.com>, Jeff Chua <jeff.chua.linux@gmail.com>,
   Tim Chen <tim.c.chen@linux.intel.com>, phil.el@wanadoo.fr, gregkh@suse.de,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Christian <christiand59@web.de>, Adrian Bunk <bunk@stusta.de>,
   linux-acpi@vger.kernel.org, mingo@redhat.com, nfs@lists.sourceforge.net,
Return-path: <linux-pm-bounces@lists.osdl.org>
To: discuss@x86-64.org
In-Reply-To: <m1r6wd3fnd.fsf@ebiederm.dsl.xmission.com>
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


> So we should have the infrastructure to only use mmconfig for some set
> of busses.  If that interface is well described we can probably
> bootstrap sanely, only enabling what we know exists and like wise
> only reserving what we know is used.

Unfortunately there is a chicken and egg problem on those few broken
systems (like some x86 Macs) where only mcfg works. Without mcfg you
won't be able to probe the bus. Ok you could trust ACPI when it says
it's there, but I'm not sure Linus would like that.

Still perhaps I guess only reserving when the bus is probed is probably
a good idea. In most cases we only probe a small number of busses =

because ACPI tells us the number.

This basically means pci_mcfg_init() should be split up.

-Andi
