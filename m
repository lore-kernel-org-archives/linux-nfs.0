From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [discuss] Re: 2.6.19-rc4: known unfixed regressions
	(v3)
Date: Tue, 7 Nov 2006 10:11:43 -0700
Message-ID: <20061107171143.GU27140@parisc-linux.org>
References: <Pine.LNX.4.64.0611080056480.12828@silvia.corp.fedex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@osdl.org>, len.brown@intel.com,
   Komuro <komurojun-mbn@nifty.com>, linux-pm@osdl.org,
   Ernst Herzberg <earny@net4u.de>, Aaron Durbin <adurbin@google.com>,
   Alex Romosan <romosan@sycorax.lbl.gov>, openib-general@openib.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-ide@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>,
   oprofile-list@lists.sourceforge.net, Jens Axboe <jens.axboe@oracle.com>,
   Martin Lorenz <martin@lorenz.eu.org>, linux-pci@atrey.karlin.mff.cuni.cz,
   Elimar Riesebieter <riesebie@lxtec.de>, discuss@x86-64.org,
   Thierry Vignaud <tvignaud@mandriva.com>,
   Tim Chen <tim.c.chen@linux.intel.com>, phil.el@wanadoo.fr, gregkh@suse.de,
   Andi Kleen <ak@suse.de>, Christian <christiand59@web.de>,
   Adrian Bunk <bunk@stusta.de>, linux-acpi@vger.kernel.org, mingo@redhat.com,
   nfs@lists.sourceforge.net, "Eric W. Bie
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Jeff Chua <jeff.chua.linux@gmail.com>
In-Reply-To: <Pine.LNX.4.64.0611080056480.12828@silvia.corp.fedex.com>
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

On Wed, Nov 08, 2006 at 12:57:03AM +0800, Jeff Chua wrote:
> 2) this fails ...
> =

> e0000000-efffffff : 0000:00:02.0
> f0000000-ffffffff : PCI MMCONFIG 0
>    fed00000-fed003ff : HPET 0

Heh, no kidding ...

                num_buses =3D pci_mmcfg_config[i].end_bus_number -
                    pci_mmcfg_config[i].start_bus_number + 1;
                res->start =3D pci_mmcfg_config[i].base_address;
                res->end =3D res->start + (num_buses << 20) - 1;
                res->flags =3D IORESOURCE_MEM | IORESOURCE_BUSY;
                insert_resource(&iomem_resource, res);

So if we have 256 busses assigned, then we request 256MB and, well,
there's no room for anyone else.  This code was added by Andi in commit
de09bddb9d6f96785be470c832b881e6d72d589f

Hopefully he'll have a good idea how to restrict it.  Given your "working"
resource map, it seems like it should be limited to 16MB (and thus 16 busse=
s).
But how to figure that out?
