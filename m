From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/4] 2.6.23-rc5: known regressions v2
Date: Sat, 08 Sep 2007 13:11:13 +0200
Message-ID: <46E28351.8050900__43560.3480124429$1189509904$gmane$org@googlemail.com>
References: <46E27DEF.7060109@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: autofs@linux.kernel.org, jfs-discussion@lists.sourceforge.net,
        Oliver Neukum <oliver@neukum.org>,
        Daniel J Blueman <daniel.blueman@gmail.com>,
        linux-usb-devel@lists.sourceforge.net,
        Andrew Clayton <andrew@digital-domain.net>, Greg KH <gregkh@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        LKML <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net,
        Dave Kleikamp <shaggy@austin.ibm.com>, linux-fsdevel@vger.kernel.org,
        Alan Stern <stern@rowland.harvard.edu>,
        Andrew Morton <akpm@linux-foundation.org>,
        Tino Keitel <tino.keitel@gmx.de>, Ian Kent <raven@themaw.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <autofs-bounces@linux.kernel.org>
In-Reply-To: <46E27DEF.7060109@googlemail.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi all,

Here is a list of some known regressions in 2.6.23-rc5.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            10
Linus Torvalds                         6
Andi Kleen                             5
Hugh Dickins                           5
Trond Myklebust                        5
Andrew Morton                          4
Al Viro                                3
Alan Stern                             3
Alexey Starikovskiy                    3
Cornelia Huck                          3
David S. Miller                        3
Jens Axboe                             3
Stephen Hemminger                      3
Tejun Heo                              3



FS

Subject         : umount triggers a warning in jfs and takes almost a minute
References      : http://lkml.org/lkml/2007/9/4/73
Last known good : ?
Submitter       : Oliver Neukum <oliver@neukum.org>
Caused-By       : ?
Handled-By      : ?
Status          : unknown

Subject         : [NFSv4] 2.6.23-rc4 oops in nfs4_cb_recall
References      : http://lkml.org/lkml/2007/9/4/53
Last known good : ?
Submitter       : Daniel J Blueman <daniel.blueman@gmail.com>
Caused-By       : ?
Handled-By      : ?
Status          : unknown

Subject         : [NFSD OOPS] 2.6.23-rc1-git10
References      : http://lkml.org/lkml/2007/8/2/462
Last known good : ?
Submitter       : Andrew Clayton <andrew@digital-domain.net>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



USB

Subject         : 2.6.23-rc1: USB hard disk broken
References      : http://lkml.org/lkml/2007/7/25/62
Last known good : ?
Submitter       : Tino Keitel <tino.keitel@gmx.de>
Caused-By       : ?
Handled-By      : Oliver Neukum <oliver@neukum.org>
Status          : unknown

Subject         : USB hard disk broken in 2.6.23-rc3 (autosuspend related)
References      : http://bugzilla.kernel.org/show_bug.cgi?id=8892
Last known good : ?
Submitter       : Roman Jarosz <kedgedev@centrum.cz>
Caused-By       : ?
Handled-By      : Alan Stern <stern@rowland.harvard.edu>
Workaround      : echo -1 >/sys/bus/usb/devices/1-4/power/autosuspend
Status          : possible hardware problem



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
