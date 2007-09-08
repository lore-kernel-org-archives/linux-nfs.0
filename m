From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/4] 2.6.23-rc5: known regressions v2
Date: Sat, 08 Sep 2007 13:11:13 +0200
Message-ID: <46E28351.8050900__38072.8043070578$1189520176$gmane$org@googlemail.com>
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
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITyEy-0005DZ-Mt
	for nfs@lists.sourceforge.net; Sat, 08 Sep 2007 04:12:40 -0700
Received: from mu-out-0910.google.com ([209.85.134.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ITyF2-0007wA-FY
	for nfs@lists.sourceforge.net; Sat, 08 Sep 2007 04:12:45 -0700
Received: by mu-out-0910.google.com with SMTP id w9so865593mue
	for <nfs@lists.sourceforge.net>; Sat, 08 Sep 2007 04:12:43 -0700 (PDT)
In-Reply-To: <46E27DEF.7060109@googlemail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

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

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
