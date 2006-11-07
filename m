From: Len Brown <len.brown@intel.com>
Subject: Re: 2.6.19-rc4: known unfixed regressions (v3)
Date: Tue, 7 Nov 2006 00:41:24 -0500
Message-ID: <200611070041.28008.len.brown@intel.com>
References: <Pine.LNX.4.64.0610302019560.25218@g5.osdl.org>
	<20061105064801.GV13381@stusta.de>
	<200611070317.42230.earny@net4u.de>
Reply-To: Len Brown <lenb@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Andrew Morton <akpm@osdl.org>, jgarzik@pobox.com,
   Thierry Vignaud <tvignaud@mandriva.com>, discuss@x86-64.org,
   Ernst Herzberg <earny@net4u.de>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Alex Romosan <romosan@sycorax.lbl.gov>, openib-general@openib.org,
   Christian <christiand59@web.de>, linux-ide@vger.kernel.org,
   Linus Torvalds <torvalds@osdl.org>, oprofile-list@lists.sourceforge.net,
   Jens Axboe <jens.axboe@oracle.com>, Martin Lorenz <martin@lorenz.eu.org>,
   "Bryan O'Sullivan" <bos@serpentine.com>,
   Elimar Riesebieter <riesebie@lxtec.de>, linux-pm@osdl.org,
   Komuro <komurojun-mbn@nifty.com>, Jeff Chua <jeff.chua.linux@gmail.com>,
   phil.el@wanadoo.fr, gregkh@suse.de, ak@suse.de,
   Adrian Bunk <bunk@stusta.de>, linux-acpi@vger.kernel.org, mingo@redhat.com,
   nfs@lists.sourceforge.net, "Eric W. Biederman" <ebiederm@xmission.com>,
   cpufreq@l
Return-path: <linux-pm-bounces@lists.osdl.org>
To: linux-pm@lists.osdl.org
In-Reply-To: <200611070317.42230.earny@net4u.de>
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

On Monday 06 November 2006 21:17, Ernst Herzberg wrote:
> On Sunday 05 November 2006 07:48, Adrian Bunk wrote:
> > ...
> > Subject    : ThinkPad R50p: boot fail with (lapic && on_battery)
> > References : http://lkml.org/lkml/2006/10/31/333
> > Submitter  : Ernst Herzberg <earny@net4u.de>
> > Status     : problem is being debugged
> =

> Update:
> =

> 2.6.19-rc4-git11 does _not_ fix the problem.
> =

> But now it doesn't matter if Cardbus/PCMCIA is compiled in or not.
> =

> What also matters is a setting in the BIOS:
> =

> If i set instead of
> =

> Power -> =

>    SpeedStep ->
>       Mode for AC -    "Max Performance"
>       Mode for Battery "Max Battery"
> =

> to
> =

> Power -> =

>    SpeedStep ->
>       Mode for AC -    "Max Battery"
>       Mode for Battery "Max Performance" =

> =

> he _does_ boot from battery but also on AC...

so with the new settings it boots properly in either AC or battery mode wit=
h forced "lapic"?
Strange, one would expect this to refer to APM settings, but who knows...

Please test if booting with "processor.max_cstate=3D1" makes any difference

Please test if building with CONFIG_CPU_FREQ=3Dn makes any difference.

Also, please make sure that booting with "apm=3Doff" makes no difference --
there is a bug where the APM code is not currently disabled in ACPI mode,
and who knows what effect that may have...

> Also the problem is now(?) not very reliable. Sometimes the boot is succe=
ssful =

> even on battery and then the laptop works without a glitch.
> This makes it not easier to isolate the problem.
> =


> Is somewhere a howto-revert-patches-in-kernel-git-for-raw-beginners?

Documentation/git-bisect.txt is what you want -- though if you can't
reliably reproduce the failure it may not easily lead you to the failure.

Also, it may be a good use of time to make darn sure that booting 2.6.18
with forced "lapic" when on battery does not fail.  ie. is this really
a regression -- of did forcing the lapic on this box never work reliably?

-Len
