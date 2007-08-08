From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/3] 2.6.23-rc2: known regressions v2
Date: Wed, 08 Aug 2007 19:11:44 +0200
Message-ID: <46B9F950.2030209__40877.5746742778$1186593792$gmane$org@googlemail.com>
References: <46B9F664.9060600@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dth <dth@dth.net>, Andrew Clayton <andrew@digital-domain.net>,
	Netdev <netdev@vger.kernel.org>, Florian Lohoff <flo@rfc822.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Uwe Bugla <uwe.bugla@gmx.de>, nfs@lists.sourceforge.net,
	Thomas Meyer <thomas@m3y3r.de>, linux-fsdevel@vger.kernel.org,
	linux-mtd@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>,
	Stephen Hemminger <shemminger@osdl.org>, Len Brown <lenb@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
In-Reply-To: <46B9F664.9060600@googlemail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
	<mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
	<mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: linux-mtd-bounces@lists.infradead.org
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-ID: <nfs.lists.sourceforge.net>

Hi all,

Here is a list of some known regressions in 2.6.23-rc2.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            6
Andi Kleen                             4
Andrew Morton                          4
Linus Torvalds                         4
Al Viro                                3
Cornelia Huck                          3
Jens Axboe                             3
Tejun Heo                              3
David Woodhouse                        2
Hugh Dickins                           2
Peter Zijlstra                         2
Trent Piepho                           2



CPUFREQ

Subject         : ide problems: 2.6.22-git17 working, 2.6.23-rc1* is not
References      : http://lkml.org/lkml/2007/7/27/298
                  http://lkml.org/lkml/2007/7/29/371
Last known good : ?
Submitter       : dth <dth@dth.net>
Caused-By       : Len Brown <lenb@kernel.org>
                  commit f79e3185dd0f8650022518d7624c876d8929061b
Handled-By      : Len Brown <lenb@kernel.org>
Status          : problem is being debugged



FS

Subject         : [NFSD OOPS] 2.6.23-rc1-git10
References      : http://lkml.org/lkml/2007/8/2/462
Last known good : ?
Submitter       : Andrew Clayton <andrew@digital-domain.net>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



MTD

Subject         : error: implicit declaration of function 'cfi_interleave'
References      : http://lkml.org/lkml/2007/8/6/272
Last known good : ?
Submitter       : Ingo Molnar <mingo@elte.hu>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



Networking

Subject         : IP v4 routing is broken
References      : http://www.stardust.webpages.pl/files/tbf/bugs/bug_report01.txt
Last known good : 2.6.22-git2
Submitter       : Uwe Bugla <uwe.bugla@gmx.de>
Caused-By       : ?
Handled-By      : ?
Status          : unknown

Subject         : New wake ups from sky2
References      : http://lkml.org/lkml/2007/7/20/386
Last known good : ?
Submitter       : Thomas Meyer <thomas@m3y3r.de>
Caused-By       : Stephen Hemminger <shemminger@osdl.org>
                  commit eb35cf60e462491249166182e3e755d3d5d91a28
Handled-By      : Stephen Hemminger <shemminger@osdl.org>
Status          : unknown



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/

______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
