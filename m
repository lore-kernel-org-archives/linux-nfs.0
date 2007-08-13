From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [1/2] 2.6.23-rc3: known regressions with patches
Date: Mon, 13 Aug 2007 19:59:54 +0200
Message-ID: <46C09C1A.7050706@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Gabriel C <nix.or.die@googlemail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	Satyam Sharma <satyam.sharma@gmail.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Dan Merillat <dan.merillat@gmail.com>,
	Paolo Ornati <ornati@fastwebnet.it>,
	Andi Kleen <andi@firstfloor.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Jeff Garzik <jeff@garzik.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi all,

Here is a list of some known regressions in 2.6.23-rc3
with patches available.

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



Unclassified

Subject         : reset during bootup - 2.6.23-rc2 (git d23cf676)
References      : http://lkml.org/lkml/2007/8/11/177
Last known good : ?
Submitter       : Dan Merillat <dan.merillat@gmail.com>
Caused-By       : Rusty Russell <rusty@rustcorp.com.au>
                  ab144f5ec64c42218a555ec1dbde6b60cf2982d6
Handled-By      : Paolo Ornati <ornati@fastwebnet.it>
                  Andi Kleen <andi@firstfloor.org>
Patch           : http://lkml.org/lkml/2007/8/12/76
Status          : patch was suggested

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
