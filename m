From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [discuss] Re: 2.6.19-rc4: known unfixed regressions
	(v3)
Date: Wed, 8 Nov 2006 08:05:18 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611080803280.3667@g5.osdl.org>
References: <Pine.LNX.4.64.0611080056480.12828@silvia.corp.fedex.com>
	<20061107171143.GU27140@parisc-linux.org>
	<200611080839.46670.ak@suse.de>
	<20061108122237.GF27140@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@osdl.org>, len.brown@intel.com,
   Thierry Vignaud <tvignaud@mandriva.com>, linux-pm@osdl.org,
   Ernst Herzberg <earny@net4u.de>, Aaron Durbin <adurbin@google.com>,
   Alex Romosan <romosan@sycorax.lbl.gov>, openib-general@openib.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-ide@vger.kernel.org, oprofile-list@lists.sourceforge.net,
   Jens Axboe <jens.axboe@oracle.com>, Martin Lorenz <martin@lorenz.eu.org>,
   linux-pci@atrey.karlin.mff.cuni.cz, Elimar Riesebieter <riesebie@lxtec.de>,
   discuss@x86-64.org, Komuro <komurojun-mbn@nifty.com>,
   Jeff Chua <jeff.chua.linux@gmail.com>,
   Tim Chen <tim.c.chen@linux.intel.com>, phil.el@wanadoo.fr, gregkh@suse.de,
   Andi Kleen <ak@suse.de>, Adrian Bunk <bunk@stusta.de>,
   linux-acpi@vger.kernel.org, mingo@redhat.com, nfs@lists.sourceforge.net,
   "Eric W. Biederman" <ebiederm@xmission.com
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20061108122237.GF27140@parisc-linux.org>
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



On Wed, 8 Nov 2006, Matthew Wilcox wrote:
>
> On Wed, Nov 08, 2006 at 08:39:44AM +0100, Andi Kleen wrote:
> > ACPI knows the number of busses.
> =

> But what if the number of busses increases later, eg by hotplugging
> a card with a PCI-PCI bridge on it?  Or does it know the number of
> busses which can be supported by this machine's MMCONFIG region?

ACPI will give the maximum number.

However, in this case, the correct thing to do (always _has_ been) is to =

not use ACPI for _anything_, but just read the base and the size of the =

MMCONFIG region from the hardware itself.

Anyway, I do not consider this a regression. MMCONFIG has _never_ worked =

reliably. It has always been a case of "we can make it work on some =

machines by making it break on others".

			Linus
