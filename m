From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [3/4] 2.6.23-rc4: known regressions
Date: Wed, 29 Aug 2007 17:27:39 +0200
Message-ID: <46D5906B.1030701__41205.0647465096$1188421263$gmane$org@googlemail.com>
References: <46D58CC6.4020605@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-wireless@vger.kernel.org,
	Michael Buesch <mbuesch@freenet.de>, Stefano Brivio <st3@riseup.net>,
	Andrew Clayton <andrew@digital-domain.net>,
	Shish <shish@shishnet.org>, Roman Zippel <zippel@linux-m68k.org>,
	Sam Ravnborg <sam@ravnborg.org>, Karl Meyer <adhocrocker@gmail.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Christian Casteyde <casteyde.christian@free.fr>,
	Francois Romieu <romieu@fr.zoreil.com>, nfs@lists.sourceforge.net,
	Netdev <netdev@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	Hugh Dickins <hugh@veritas.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kbuild-devel@lists.sourceforge.net,
	Martin Langer <martin-langer@gmx.de>,
	Andreas Jaggi <andreas.jaggi@waterwave.ch>,
	Danny van Dyk <kugelfang@gentoo.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQPTG-0001EX-2y
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 08:28:42 -0700
Received: from nf-out-0910.google.com ([64.233.182.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQPTI-0006NV-5G
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 08:28:46 -0700
Received: by nf-out-0910.google.com with SMTP id 4so525707nfv
	for <nfs@lists.sourceforge.net>; Wed, 29 Aug 2007 08:28:42 -0700 (PDT)
In-Reply-To: <46D58CC6.4020605@googlemail.com>
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

Here is a list of some known regressions in 2.6.23-rc4.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            9
Andi Kleen                             5
Linus Torvalds                         5
Andrew Morton                          4
Hugh Dickins                           4
Al Viro                                3
Alan Stern                             3
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



Kconfig

Subject         : CONFIG_HOTPLUG_CPU: kconfig bug?
References      : http://lkml.org/lkml/2007/8/27/204
Last known good : ?
Submitter       : Hugh Dickins <hugh@veritas.com>
Caused-By       : ?
Handled-By      : Sam Ravnborg <sam@ravnborg.org>
Status          : problem is being debugged



Networking

Subject         : System freeze when restarting network connection with Broadcom driver
References      : http://bugzilla.kernel.org/show_bug.cgi?id=8934
Last known good : ?
Submitter       : Christian Casteyde <casteyde.christian@free.fr>
Caused-By       : ?
Handled-By      : ?
Status          : problem is being debugged

Subject         : NETDEV WATCHDOG: eth0: transmit timed out
References      : http://lkml.org/lkml/2007/8/13/737
Last known good : ?
Submitter       : Karl Meyer <adhocrocker@gmail.com>
Caused-By       : ?
Handled-By      : Francois Romieu <romieu@fr.zoreil.com>
Status          : problem is being debugged

Subject         : Weird network problems with 2.6.23-rc2
References      : http://lkml.org/lkml/2007/8/11/40
Last known good : ?
Submitter       : Shish <shish@shishnet.org>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
