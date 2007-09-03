From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/4] 2.6.23-rc5: known regressions
Date: Mon, 03 Sep 2007 12:10:19 +0200
Message-ID: <46DBDD8B.7040706__46109.2618098066$1188841324$gmane$org@googlemail.com>
References: <46DBD982.3080102@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dth <dth@dth.net>, Jeff Chua <jeff.chua.linux@gmail.com>,
	"Antonino A. Daplas" <adaplas@gmail.com>,
	Peter Kovar <peter.kovar@gmail.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	LKML <linux-kernel@vger.kernel.org>, Markus <lists4me@web.de>,
	nfs@lists.sourceforge.net, "H. Peter Anvin" <hpa@zytor.com>,
	linux-fsdevel@vger.kernel.org,
	Andrew Clayton <andrew@digital-domain.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Len Brown <lenb@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISFqj-0005Wj-Pk
	for nfs@lists.sourceforge.net; Mon, 03 Sep 2007 10:36:33 -0700
Received: from nf-out-0910.google.com ([64.233.182.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IS8tT-0002cP-MK
	for nfs@lists.sourceforge.net; Mon, 03 Sep 2007 03:10:58 -0700
Received: by nf-out-0910.google.com with SMTP id 30so1121445nfu
	for <nfs@lists.sourceforge.net>; Mon, 03 Sep 2007 03:10:54 -0700 (PDT)
In-Reply-To: <46DBD982.3080102@googlemail.com>
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
Adrian Bunk                            9
Linus Torvalds                         6
Andi Kleen                             5
Hugh Dickins                           5
Andrew Morton                          4
Al Viro                                3
Alan Stern                             3
Alexey Starikovskiy                    3
Cornelia Huck                          3
Jens Axboe                             3
Stephen Hemminger                      3
Tejun Heo                              3



Unclassified

Subject         : console is messed up after resume from s2ram or switching to console from X
References      : http://lkml.org/lkml/2007/8/4/6
Last known good : ?
Submitter       : Jeff Chua <jeff.chua.linux@gmail.com>
Caused-By       : ?
Handled-By      : H. Peter Anvin <hpa@zytor.com>
                  Antonino A. Daplas <adaplas@gmail.com>
Workaround      : "s2ram --force --acpi_sleep 1 --vbe_mode"
Status          : problem is being debugged

Subject         : konqueror suddenly vanishing, "konqueror: Fatal IO error: client killed"
References      : http://lkml.org/lkml/2007/7/22/86
Last known good : ?
Submitter       : Markus <lists4me@web.de>
Caused-By       : ?
Handled-By      : Ingo Molnar <mingo@elte.hu>
Status          : problem is being debugged



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

Subject         : NFSv3 server error in LOOKUP after READDIRPLUS Call
References      : http://bugzilla.kernel.org/show_bug.cgi?id=8966
Last known good : ?
Submitter       : Peter Kovar <peter.kovar@gmail.com>
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
