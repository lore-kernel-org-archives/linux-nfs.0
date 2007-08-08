From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/3] 2.6.23-rc2: known regressions v2
Date: Wed, 08 Aug 2007 19:11:44 +0200
Message-ID: <46B9F950.2030209__26972.8500898511$1186614206$gmane$org@googlemail.com>
References: <46B9F664.9060600@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dth <dth@dth.net>, Andrew Clayton <andrew@digital-domain.net>,
	Netdev <netdev@vger.kernel.org>, Florian Lohoff <flo@rfc822.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	LKML <linux-kernel@vger.kernel.org>, Uwe Bugla <uwe.bugla@gmx.de>,
	nfs@lists.sourceforge.net, Thomas Meyer <thomas@m3y3r.de>,
	linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@elte.hu>,
	Stephen Hemminger <shemminger@osdl.org>, Len Brown <lenb@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIp4j-0005Ah-Fh
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 10:12:01 -0700
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIp4m-0006im-Ln
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 10:12:05 -0700
Received: by ug-out-1314.google.com with SMTP id m2so256705uge
	for <nfs@lists.sourceforge.net>; Wed, 08 Aug 2007 10:12:03 -0700 (PDT)
In-Reply-To: <46B9F664.9060600@googlemail.com>
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

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
