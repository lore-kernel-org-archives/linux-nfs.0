From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/4] 2.6.23-rc6: known regressions
Date: Wed, 12 Sep 2007 18:58:54 +0200
Message-ID: <46E81ACE.6030305__24436.4738850438$1189617875$gmane$org@googlemail.com>
References: <46E8187E.9000006@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: jfs-discussion@lists.sourceforge.net,
	Daniel J Blueman <daniel.blueman@gmail.com>,
	Andrew Clayton <andrew@digital-domain.net>, sct@redhat.com,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-acpi@vger.kernel.org,
	nfs@lists.sourceforge.net, Dave Kleikamp <shaggy@austin.ibm.com>,
	Chuck Ebbert <cebbert@redhat.com>, Andy Whitcroft <apw@shadowen.org>,
	linux-fsdevel@vger.kernel.org, dth <dth@dth.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-ext4@vger.kernel.org, adilger@clusterfs.com,
	Len Brown <lenb@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVVYy-00013U-BD
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:59:40 -0700
Received: from nf-out-0910.google.com ([64.233.182.191])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVVZ2-0002dD-IW
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:59:45 -0700
Received: by nf-out-0910.google.com with SMTP id 4so760593nfv
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:59:43 -0700 (PDT)
In-Reply-To: <46E8187E.9000006@googlemail.com>
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

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
