From: "Jeff Chua" <jeff.chua.linux@gmail.com>
Subject: Re: 2.6.19-rc4: known unfixed regressions (v3)
Date: Sun, 5 Nov 2006 17:30:27 +0800
Message-ID: <b6a2187b0611050130s325d777che069a7d9619f061b@mail.gmail.com>
References: <Pine.LNX.4.64.0610302019560.25218@g5.osdl.org>
	<20061105064801.GV13381@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@osdl.org>, len.brown@intel.com,
   Komuro <komurojun-mbn@nifty.com>, linux-pm@osdl.org,
   Ernst Herzberg <earny@net4u.de>, Christian <christiand59@web.de>,
   Alex Romosan <romosan@sycorax.lbl.gov>, openib-general@openib.org,
   ak@suse.de, linux-ide@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>,
   oprofile-list@lists.sourceforge.net, Jens Axboe <jens.axboe@oracle.com>,
   linux-pci@atrey.karlin.mff.cuni.cz, Elimar Riesebieter <riesebie@lxtec.de>,
   discuss@x86-64.org, Thierry Vignaud <tvignaud@mandriva.com>,
   Tim Chen <tim.c.chen@linux.intel.com>, phil.el@wanadoo.fr, gregkh@suse.de,
   neilb@cse.unsw.edu.au,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-acpi@vger.kernel.org, mingo@redhat.com, nfs@lists.sourceforge.net,
   "Eric W. Biederman" <ebiederm@xmission.com>, cpufreq@lists.linux.org.uk,
   "Michael S. Tsirkin" <mst@mellan
Return-path: <linux-pm-bounces@lists.osdl.org>
To: "Adrian Bunk" <bunk@stusta.de>
In-Reply-To: <20061105064801.GV13381@stusta.de>
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

On 11/5/06, Adrian Bunk <bunk@stusta.de> wrote:

> Subject    : PCI: MMCONFIG breakage
> References : http://lkml.org/lkml/2006/10/27/251
> Submitter  : Jeff Chua <jeff.chua.linux@gmail.com>
> Status     : unknown, both BIOS and Direct work
>              Greg said it should already be fixed

Here's results with vanilla 2.6.19-rc4 (gcc version 3.4.5) ...

1) PCI access mode (Any) ... FAILED

2) PCI access mode (MMConfig) ... FAILED

3) PCI access mode (Direct) ... PASSED

4) PCI access mode (BIOS) ... PASSED

Looks like it's still having problem with Dell Optiplex GX620.

Thanks,
Jeff.
