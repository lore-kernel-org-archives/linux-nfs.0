From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/4] 2.6.23-rc6: known regressions
Date: Wed, 12 Sep 2007 18:58:54 +0200
Message-ID: <46E81ACE.6030305__20641.8618131012$1189616415$gmane$org@googlemail.com>
References: <46E8187E.9000006@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Clayton <andrew@digital-domain.net>,
	Daniel J Blueman <daniel.blueman@gmail.com>,
	Dave Kleikamp <shaggy@austin.ibm.com>,
	jfs-discussion@lists.sourceforge.net,
	Andy Whitcroft <apw@shadowen.org>, sct@redhat.com,
	adilger@clusterfs.com, linux-ext4@vger.kernel.org,
	linux-acpi@vger.kernel.org, Len Brown <lenb@kernel.org>,
	Chuck Ebbert <cebbert@redhat.com>, dth <dth@dth.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <46E8187E.9000006@googlemail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi all,

Here is a list of some known regressions in 2.6.23-rc6.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            10
Linus Torvalds                         6
Alan Stern                             5
Andi Kleen                             5
Hugh Dickins                           5
Trond Myklebust                        5
Andrew Morton                          4
Al Viro                                3
Alexey Starikovskiy                    3
Cornelia Huck                          3
David S. Miller                        3
Jens Axboe                             3
Stephen Hemminger                      3
Tejun Heo                              3



ACPI

Subject         : 2.6.23-rc5 hangs on boot, apparently when initializing the EC
References      : http://lkml.org/lkml/2007/9/11/369
Last known good : ?
Submitter       : Chuck Ebbert <cebbert@redhat.com>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



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

Subject         : hanging ext3 dbench tests
References      : http://lkml.org/lkml/2007/9/11/176
Last known good : ?
Submitter       : Andy Whitcroft <apw@shadowen.org>
Caused-By       : ?
Handled-By      : ?
Status          : unknown

Subject         : umount triggers a warning in jfs and takes almost a minute
References      : http://lkml.org/lkml/2007/9/4/73
Last known good : ?
Submitter       : Oliver Neukum <oliver@neukum.org>
Caused-By       : ?
Handled-By      : ?
Status          : unknown

Subject         : [NFSv4] 2.6.23-rc4 oops in nfs4_cb_recall
References      : http://lkml.org/lkml/2007/9/4/53
                  http://bugzilla.kernel.org/show_bug.cgi?id=9003
Last known good : ?
Submitter       : Daniel J Blueman <daniel.blueman@gmail.com>
Caused-By       : ?
Handled-By      : ?
Workaround      : http://bugzilla.kernel.org/attachment.cgi?id=12797
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
