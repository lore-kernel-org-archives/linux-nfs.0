From: Ernst Herzberg <earny@net4u.de>
Subject: Re: 2.6.19-rc4: known unfixed regressions (v3)
Date: Tue, 7 Nov 2006 03:17:34 +0100
Message-ID: <200611070317.42230.earny@net4u.de>
References: <Pine.LNX.4.64.0610302019560.25218@g5.osdl.org>
	<20061105064801.GV13381@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@osdl.org>, len.brown@intel.com,
   Komuro <komurojun-mbn@nifty.com>, linux-pm@osdl.org,
   Christian <christiand59@web.de>, Alex Romosan <romosan@sycorax.lbl.gov>,
   openib-general@openib.org, ak@suse.de, linux-ide@vger.kernel.org,
   Linus Torvalds <torvalds@osdl.org>, oprofile-list@lists.sourceforge.net,
   Jens Axboe <jens.axboe@oracle.com>, linux-pci@atrey.karlin.mff.cuni.cz,
   Elimar Riesebieter <riesebie@lxtec.de>, discuss@x86-64.org,
   Thierry Vignaud <tvignaud@mandriva.com>,
   Jeff Chua <jeff.chua.linux@gmail.com>,
   Tim Chen <tim.c.chen@linux.intel.com>, phil.el@wanadoo.fr, gregkh@suse.de,
   neilb@cse.unsw.edu.au,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-acpi@vger.kernel.org, mingo@redhat.com, nfs@lists.sourceforge.net,
   "Eric W. Biederman" <ebiederm@xmission.com>, cpufreq@lists.linux.org.uk,
   "Michael S. Tsirkin" <m
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Adrian Bunk <bunk@stusta.de>
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

On Sunday 05 November 2006 07:48, Adrian Bunk wrote:
> ...
> Subject    : ThinkPad R50p: boot fail with (lapic && on_battery)
> References : http://lkml.org/lkml/2006/10/31/333
> Submitter  : Ernst Herzberg <earny@net4u.de>
> Status     : problem is being debugged

Update:

2.6.19-rc4-git11 does _not_ fix the problem.

But now it doesn't matter if Cardbus/PCMCIA is compiled in or not.

What also matters is a setting in the BIOS:

If i set instead of

Power -> =

   SpeedStep ->
      Mode for AC -    "Max Performance"
      Mode for Battery "Max Battery"

to

Power -> =

   SpeedStep ->
      Mode for AC -    "Max Battery"
      Mode for Battery "Max Performance" =


he _does_ boot from battery but also on AC...

Also the problem is now(?) not very reliable. Sometimes the boot is success=
ful =

even on battery and then the laptop works without a glitch.
This makes it not easier to isolate the problem.

About the reverts of some patches: I'm not, lets say it carefull, an very   =

experienced git user;-) =

What i get is:

# git-revert -n cf4c6a2f27f5db810b69dcb1da7f194489e8ff88
First trying simple merge strategy to revert.
Simple revert fails; trying Automatic revert.
Auto-merging arch/i386/kernel/io_apic.c
merge: warning: conflicts during merge
ERROR: Merge conflict in arch/i386/kernel/io_apic.c
....


Is somewhere a howto-revert-patches-in-kernel-git-for-raw-beginners?

<earny>
