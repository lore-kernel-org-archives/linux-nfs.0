From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [4/4] 2.6.23-rc3: known regressions
Date: Mon, 13 Aug 2007 19:59:45 +0200
Message-ID: <46C09C11.3070105__3447.12308510697$1187029187$gmane$org@googlemail.com>
References: <46C098FD.1030601@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-usb-devel@lists.sourceforge.net, Greg KH <gregkh@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oliver@neukum.org>,
	Tino Keitel <tino.keitel@gmx.de>,
	"Stuart_Hayes@Dell.com" <Stuart_Hayes@Dell.com>,
	Daniel Exner <dex@dragonslave.de>,
	kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>,
	Paolo Ornati <ornati@fastwebnet.it>,
	linux-alpha@vger.kernel.org, Richard Henderson <rth@twiddle.net>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Oliver Falk <oliver@linux-kernel.at>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Clayton <andrew@digital-domain.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S939594AbXHMSTY@vger.kernel.org>
In-Reply-To: <46C098FD.1030601@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi all,

Here is a list of some known regressions in 2.6.23-rc3.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            9
Andi Kleen                             5
Linus Torvalds                         5
Andrew Morton                          4
Al Viro                                3
Cornelia Huck                          3
Jens Axboe                             3
Tejun Heo                              3



FS

Subject         : [NFSD OOPS] 2.6.23-rc1-git10
References      : http://lkml.org/lkml/2007/8/2/462
Last known good : ?
Submitter       : Andrew Clayton <andrew@digital-domain.net>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



USB

Subject         : EHCI Regression in 2.6.23-rc2
References      : http://lkml.org/lkml/2007/8/10/81
Last known good : ?
Submitter       : Daniel Exner <dex@dragonslave.de>
Caused-By       : Stuart_Hayes@Dell.com <Stuart_Hayes@Dell.com>
                  commit 196705c9bbc03540429b0f7cf9ee35c2f928a534
Handled-By      : ?
Status          : unknown

Subject         : 2.6.23-rc1: USB hard disk broken
References      : http://lkml.org/lkml/2007/7/25/62
Last known good : ?
Submitter       : Tino Keitel <tino.keitel@gmx.de>
Caused-By       : ?
Handled-By      : Oliver Neukum <oliver@neukum.org>
Status          : unknown



Virtualization

Subject         : WARNING: at arch/x86_64/kernel/smp.c:379 smp_call_function_single()
References      : http://lkml.org/lkml/2007/8/10/117
Last known good : ?
Submitter       : Paolo Ornati <ornati@fastwebnet.it>
Caused-By       : Avi Kivity <avi@qumranet.com>
                  commit cec9ad279b66793bee0b5009b7ca311060061efd
Handled-By      : Avi Kivity <avi@qumranet.com>
Status          : problem is being debugged



Alpha

Subject         : -Werror compilation problem - make[1]: *** [arch/alpha/kernel/sys_titan.o] Error 1
References      : http://lkml.org/lkml/2007/8/6/137
Last known good : ?
Submitter       : Oliver Falk <oliver@linux-kernel.at>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
