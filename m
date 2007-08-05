From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [1/2] 2.6.23-rc2: known regressions with patches
Date: Sun, 05 Aug 2007 18:26:43 +0200
Message-ID: <46B5FA43.9010809__22478.1562145383$1186614193$gmane$org@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Gabriel C <nix.or.die@googlemail.com>,
	Stefan Richter
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IHixN-0001v2-A2
	for nfs@lists.sourceforge.net; Sun, 05 Aug 2007 09:27:53 -0700
Received: from mu-out-0910.google.com ([209.85.134.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IHixQ-0005hu-VC
	for nfs@lists.sourceforge.net; Sun, 05 Aug 2007 09:27:57 -0700
Received: by mu-out-0910.google.com with SMTP id w9so1300435mue
	for <nfs@lists.sourceforge.net>; Sun, 05 Aug 2007 09:27:56 -0700 (PDT)
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

Here is a list of some known regressions in 2.6.23-rc2
with patches available.

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
Trent Piepho                           2



Unclassified

Subject         : Kconfig prompts without help text
References      : http://lkml.org/lkml/2007/7/16/326
Last known good : ?
Submitter       : Stefan Richter <stefanr@s5r6.in-berlin.de>
Caused-By       : ?
Handled-By      : Jan Engelhardt <jengelh@linux01.gwdg.de>
Patch           : http://lkml.org/lkml/2007/7/18/236
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



ACPI

Subject         : acpi_ec_remove() use-after-free
References      : http://lkml.org/lkml/2007/7/29/138
Last known good : 2.6.22
Submitter       : Adrian Bunk <bunk@stusta.de>
Caused-By       : Alexey Starikovskiy <astarikovskiy@suse.de>
                  commit 837012ede14a8fc088be3682c964da7fc6af026b
Handled-By      : Adrian Bunk <bunk@stusta.de>
Patch           : http://lkml.org/lkml/2007/7/29/138
Status          : patch available

Subject         : Time Problems with 2.6.23-rc1-gf695baf2
References      : http://lkml.org/lkml/2007/7/23/486
Last known good : ?
Submitter       : Eric Sesterhenn <snakebyte@gmx.de>
Caused-By       : Venki Pallipadi <venkatesh.pallipadi@intel.com>
                  commit 18eab8550397f1f3d4b8b2c5257c88dae25d58ed
Handled-By      : ?
Patch           : http://marc.info/?l=linux-kernel&m=118590919604954&w=2
Status          : patch available



FS

Subject         : NFSv4 poops itself
References      : http://lkml.org/lkml/2007/7/27/144
Last known good : ?
Submitter       : Jeff Garzik <jeff@garzik.org> 
Caused-By       : ?
Handled-By      : Trond Myklebust <Trond.Myklebust@netapp.com>
Patch           : http://lkml.org/lkml/2007/7/27/183
Status          : patch available



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
