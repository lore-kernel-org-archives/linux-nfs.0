From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [1/2] 2.6.23-rc5: known regressions with patches
Date: Mon, 03 Sep 2007 12:11:03 +0200
Message-ID: <46DBDDB7.2090806__23409.8998051651$1188825708$gmane$org@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: autofs@linux.kernel.org, Gabriel C <nix.or.die@googlemail.com>,
	Hua Zhong <hzhong@gmail.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	linux-ide@vger.kernel.org, Vitaly Bordug <vitb@kernel.crashing.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Tony Breeds <tony@bakeyournoodle.com>, Ian Kent <raven@themaw.net>,
	Harry Edmon <harry@atmos.washington.edu>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org,
	Satyam Sharma <satyam.sharma@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrey Borzenkov <arvidjaar@mail.ru>, Bret Towe <magnade@gmail.com>,
	Bjorn Helgaas <bjorn.helgaas@hp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISBNX-0002FT-Ic
	for nfs@lists.sourceforge.net; Mon, 03 Sep 2007 05:50:07 -0700
Received: from wx-out-0506.google.com ([66.249.82.232])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IS8uC-0003Av-Uz
	for nfs@lists.sourceforge.net; Mon, 03 Sep 2007 03:11:41 -0700
Received: by wx-out-0506.google.com with SMTP id h31so1468716wxd
	for <nfs@lists.sourceforge.net>; Mon, 03 Sep 2007 03:11:40 -0700 (PDT)
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

Here is a list of some known regressions in 2.6.23-rc5
with patches available.

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

Subject         : 8250 claims non existing device blocking IO port
References      : http://lkml.org/lkml/2007/8/18/20
Last known good : ?
Submitter       : Andrey Borzenkov <arvidjaar@mail.ru>
Caused-By       : ?
Handled-By      : Bjorn Helgaas <bjorn.helgaas@hp.com>
Patch           : http://lkml.org/lkml/2007/8/21/291
Status          : patch available

Subject         : Oops while modprobing phy fixed module
References      : http://lkml.org/lkml/2007/7/14/63
Last known good : ?
Submitter       : Gabriel C <nix.or.die@googlemail.com>
Caused-By       : ?
Handled-By      : Satyam Sharma <satyam.sharma@gmail.com>
                  Vitaly Bordug <vitb@kernel.crashing.org>
Patch1          : http://lkml.org/lkml/2007/7/18/506
Status          : patch available



FS

Subject         : NFSv4 client OOPS
References      : http://lkml.org/lkml/2007/8/28/207
Last known good : ?
Submitter       : Harry Edmon <harry@atmos.washington.edu>
Caused-By       : ?
Handled-By      : Trond Myklebust <Trond.Myklebust@netapp.com>
Patch           : http://lkml.org/lkml/2007/8/28/204
Status          : patch available

Subject         : autofs mounts mysteriously disappeared
References      : http://lkml.org/lkml/2007/8/29/222
                  http://lkml.org/lkml/2007/8/30/234
Last known good : 2.6.22
Submitter       : Hua Zhong <hzhong@gmail.com>
Caused-By       : ?
Handled-By      : Trond Myklebust <Trond.Myklebust@netapp.com>
Patch           : http://lkml.org/lkml/2007/8/31/189
Status          : patch available



IDE

Subject         : linux-2.6.23-rc4 ppc build failure
References      : http://lkml.org/lkml/2007/8/29/154
Last known good : ?
Submitter       : Bret Towe <magnade@gmail.com>
Caused-By       : ?
Handled-By      : Tony Breeds <tony@bakeyournoodle.com>
Patch           : http://lkml.org/lkml/2007/8/31/1
Status          : patch was suggested



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
