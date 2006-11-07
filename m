From: "Aaron Durbin" <adurbin@google.com>
Subject: Re: [discuss] Re: 2.6.19-rc4: known unfixed regressions
	(v3)
Date: Tue, 7 Nov 2006 09:11:16 -0800
Message-ID: <8f95bb250611070911p612a332p20e406429759fbf4@mail.gmail.com>
References: <Pine.LNX.4.64.0611080056480.12828@silvia.corp.fedex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@osdl.org>, len.brown@intel.com,
   Komuro <komurojun-mbn@nifty.com>, linux-pm@osdl.org,
   Ernst Herzberg <earny@net4u.de>, Christian <christiand59@web.de>,
   Alex Romosan <romosan@sycorax.lbl.gov>, openib-general@openib.org,
   Andi Kleen <ak@suse.de>, linux-ide@vger.kernel.org,
   Linus Torvalds <torvalds@osdl.org>, oprofile-list@lists.sourceforge.net,
   Jens Axboe <jens.axboe@oracle.com>, Martin Lorenz <martin@lorenz.eu.org>,
   linux-pci@atrey.karlin.mff.cuni.cz, Elimar Riesebieter <riesebie@lxtec.de>,
   discuss@x86-64.org, Thierry Vignaud <tvignaud@mandriva.com>,
   Tim Chen <tim.c.chen@linux.intel.com>, phil.el@wanadoo.fr, gregkh@suse.de,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Adrian Bunk <bunk@stusta.de>, linux-acpi@vger.kernel.org, mingo@redhat.com,
   nfs@lists.sourceforge.net, "Eric W. Biederman" <ebiederm@xmission.com>,
   cp
Return-path: <linux-pm-bounces@lists.osdl.org>
To: "Jeff Chua" <jeff.chua.linux@gmail.com>
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

On 11/7/06, Jeff Chua <jeff.chua.linux@gmail.com> wrote:
>
> On 11/7/06, Aaron Durbin <adurbin@google.com> wrote:
>
> > Could please you post a dump of /proc/iomem for both the kernel that
> > works for you and the kernel that fails to allocate the PCI resources?
>
>
>
> 1) this works ...
>
> 00000000-0009ffff : System RAM
> 000a0000-000bffff : Video RAM area
> 000c0000-000c7fff : Video ROM
> 000cc800-000cffff : Adapter ROM
> 000f0000-000fffff : System ROM
> 00100000-df686bff : System RAM
>     00100000-00357d27 : Kernel code
>     00357d28-0042bab3 : Kernel data
> df686c00-df688bff : ACPI Non-volatile Storage
> df688c00-df68abff : ACPI Tables
> df68ac00-dfffffff : reserved
> e0000000-efffffff : 0000:00:02.0
> f0000000-f3ffffff : reserved
> fe700000-fe7fffff : PCI Bus #03
> fe800000-fe8fffff : PCI Bus #02
>     fe8f0000-fe8fffff : 0000:02:00.0
>       fe8f0000-fe8fffff : tg3
> fe900000-fe9fffff : PCI Bus #01
> feabf900-feabf9ff : 0000:00:1e.2
> feabfa00-feabfbff : 0000:00:1e.2
> feac0000-feafffff : 0000:00:02.0
> feb00000-feb7ffff : 0000:00:02.0
> feb80000-febfffff : 0000:00:02.1
> fed00000-fed003ff : HPET 0
> fed20000-fed9ffff : reserved
> fee00000-feefffff : reserved
> ffa80800-ffa80bff : 0000:00:1d.7
>     ffa80800-ffa80bff : ehci_hcd
> ffb00000-ffffffff : reserved
>
>
>
> 2) this fails ...
>
> 00000000-0009ffff : System RAM
> 000a0000-000bffff : Video RAM area
> 000c0000-000c7fff : Video ROM
> 000cc800-000cffff : Adapter ROM
> 000f0000-000fffff : System ROM
> 00100000-df686bff : System RAM
>     00100000-00358927 : Kernel code
>     00358928-0042cab3 : Kernel data
> df686c00-df688bff : ACPI Non-volatile Storage
> df688c00-df68abff : ACPI Tables
> df68ac00-dfffffff : reserved
> e0000000-efffffff : 0000:00:02.0
> f0000000-ffffffff : PCI MMCONFIG 0
>     fed00000-fed003ff : HPET 0
>

Ok. Jeff I have patch in there that reserves the MMCONFIG space,
however it is marked as reserved during resource insertion. For some
reason your MMCONFIG space is being reported as very large, thus
reserving the range f0000000-ffffffff. That is why your PCI devices
are bombing out on resource allocation. It looks like the MMCONFIG
region should be:
f0000000-f3ffffff. This range is marked as reserved in your e820 map,
however the MMCONFIG parsing is thinking it is 256MB.

This is not the right answer, but you could patch up your kernel to
fix it to the correct size  for a temporary fix. I am going to see if
I can parse any other information from your logs and see if I can come
up w/ a better solution.

I just wanted to point you and others in the right direction.

-Aaron
