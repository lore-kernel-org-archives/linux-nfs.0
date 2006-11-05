From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.19-rc4: known unfixed regressions (v3)
Date: Sun, 5 Nov 2006 07:48:01 +0100
Message-ID: <20061105064801.GV13381@stusta.de>
References: <Pine.LNX.4.64.0610302019560.25218@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: len.brown@intel.com, Komuro <komurojun-mbn@nifty.com>, linux-pm@osdl.org,
   Ernst Herzberg <earny@net4u.de>, Christian <christiand59@web.de>,
   Alex Romosan <romosan@sycorax.lbl.gov>, openib-general@openib.org,
   ak@suse.de, linux-ide@vger.kernel.org, oprofile-list@lists.sourceforge.net,
   Jens Axboe <jens.axboe@oracle.com>, linux-pci@atrey.karlin.mff.cuni.cz,
   Elimar Riesebieter <riesebie@lxtec.de>, discuss@x86-64.org,
   Thierry Vignaud <tvignaud@mandriva.com>,
   Jeff Chua <jeff.chua.linux@gmail.com>,
   Tim Chen <tim.c.chen@linux.intel.com>, phil.el@wanadoo.fr, gregkh@suse.de,
   neilb@cse.unsw.edu.au,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-acpi@vger.kernel.org, mingo@redhat.com, nfs@lists.sourceforge.net,
   "Eric W. Biederman" <ebiederm@xmission.com>, cpufreq@lists.linux.org.uk,
   "Michael S. Tsirkin" <mst@mellanox.co.il>,
   "Bryan O'Sulli
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0610302019560.25218@g5.osdl.org>
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

This email lists some known regressions in 2.6.19-rc4 compared to 2.6.18
that are not yet fixed in Linus' tree.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way possibly
involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : ipath driver MCEs system on load when HT chip present
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D7455
Submitter  : Bryan O'Sullivan <bos@serpentine.com>
Caused-By  : Eric W. Biederman <ebiederm@xmission.com>
Status     : unknown


Subject    : i386: more DWARFs and strange messages
References : http://lkml.org/lkml/2006/10/29/127
Submitter  : Martin Lorenz <martin@lorenz.eu.org>
Status     : unknown


Subject    : x86_64: oprofile doesn't work
References : http://lkml.org/lkml/2006/10/27/3
Submitter  : Prakash Punnoor <prakash@punnoor.de>
Status     : unknown


Subject    : sata-via doesn't detect anymore disks attached to VIA vt6421
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D7255
Submitter  : Thierry Vignaud <tvignaud@mandriva.com>
Status     : unknown


Subject    : unable to rip cd
References : http://lkml.org/lkml/2006/10/13/100
Submitter  : Alex Romosan <romosan@sycorax.lbl.gov>
Status     : unknown


Subject    : SMP kernel can not generate ISA irq properly
References : http://lkml.org/lkml/2006/10/22/15
Submitter  : Komuro <komurojun-mbn@nifty.com>
Status     : unknown


Subject    : nfs-kernel-server does not start
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D7457
Submitter  : Elimar Riesebieter <riesebie@lxtec.de>
Status     : problem is being debugged


Subject    : ThinkPad T60/X60: lose ACPI events after suspend/resume
References : http://lkml.org/lkml/2006/10/10/39
             http://lkml.org/lkml/2006/10/4/425
             http://lkml.org/lkml/2006/10/16/262
             http://bugzilla.kernel.org/show_bug.cgi?id=3D7408
             http://lkml.org/lkml/2006/10/30/251
             http://lkml.org/lkml/2006/11/3/244
Submitter  : Martin Lorenz <martin@lorenz.eu.org>
             "Michael S. Tsirkin" <mst@mellanox.co.il>
Status     : problem is being debugged


Subject    : ThinkPad R50p: boot fail with (lapic && on_battery)
References : http://lkml.org/lkml/2006/10/31/333
Submitter  : Ernst Herzberg <earny@net4u.de>
Status     : problem is being debugged


Subject    : x86_64: NR_IRQ increase causes 11.5% slowdown
                     in lmbench's fork benchmark
References : http://lkml.org/lkml/2006/11/2/192
Submitter  : Tim Chen <tim.c.chen@linux.intel.com>
Caused-By  : Eric W. Biederman <ebiederm@xmission.com>
             commit 550f2299ac8ffaba943cf211380d3a8d3fa75301
Handled-By : Eric W. Biederman <ebiederm@xmission.com>
             Andi Kleen <ak@suse.de>
Status     : problem is being debugged


Subject    : cpufreq not working on AMD K8
References : http://lkml.org/lkml/2006/10/10/114
             http://lkml.org/lkml/2006/11/3/26
Submitter  : Christian <christiand59@web.de>
Handled-By : Dave Jones <davej@redhat.com>
Status     : Dave is investigating


Subject    : PCI: MMCONFIG breakage
References : http://lkml.org/lkml/2006/10/27/251
Submitter  : Jeff Chua <jeff.chua.linux@gmail.com>
Status     : unknown, both BIOS and Direct work
             Greg said it should already be fixed
