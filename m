From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [discuss] Re: 2.6.19-rc4: known unfixed regressions
	(v3)
Date: Tue, 7 Nov 2006 10:56:52 -0700
Message-ID: <20061107175651.GV27140@parisc-linux.org>
References: <Pine.LNX.4.64.0611080056480.12828@silvia.corp.fedex.com>
	<20061107171143.GU27140@parisc-linux.org>
	<8f95bb250611070950m3dc45674gbd370e3173b6168d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@osdl.org>, len.brown@intel.com,
   Thierry Vignaud <tvignaud@mandriva.com>, linux-pm@osdl.org,
   Ernst Herzberg <earny@net4u.de>, Christian <christiand59@web.de>,
   Alex Romosan <romosan@sycorax.lbl.gov>, openib-general@openib.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-ide@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>,
   oprofile-list@lists.sourceforge.net, Jens Axboe <jens.axboe@oracle.com>,
   linux-pci@atrey.karlin.mff.cuni.cz, Elimar Riesebieter <riesebie@lxtec.de>,
   discuss@x86-64.org, Komuro <komurojun-mbn@nifty.com>,
   Jeff Chua <jeff.chua.linux@gmail.com>,
   Tim Chen <tim.c.chen@linux.intel.com>, phil.el@wanadoo.fr,
   cpufreq@lists.linux.org.uk, gregkh@suse.de, neilb@cse.unsw.edu.au,
   Adrian Bunk <bunk@stusta.de>, linux-acpi@vger.kernel.org, mingo@redhat.com,
   nfs@lists.sourceforge.net, "Eric W. Biederman"
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Aaron Durbin <adurbin@google.com>
In-Reply-To: <8f95bb250611070950m3dc45674gbd370e3173b6168d@mail.gmail.com>
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

On Tue, Nov 07, 2006 at 09:50:54AM -0800, Aaron Durbin wrote:
> Maybe Andi can shed some light on the reasoning for not checking e820
> to see if the entire MMCONFIG region is reported as reserved in the
> e820 map.  I can patch up the pci_mmcfg_insert_resource to verify if
> the region that is exported by ACPI is reserved in e820 and printk an
> error message if it is not and skip the resource insertion.
> =

> Does that seem like a good avenue to pursue?

Sounds much better than Eric's idea of maximum bus number currently in
use (which was also my first thought).

But rather than skipping the resource insertion, I believe you should
limit its size to the largest multiple of 1MB that will fit within the
reserved region.
