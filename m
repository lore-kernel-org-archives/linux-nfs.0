From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [4/4] 2.6.23-rc3: known regressions
Date: Mon, 13 Aug 2007 19:59:45 +0200
Message-ID: <46C09C11.3070105__20804.3819213801$1187050895$gmane$org@googlemail.com>
References: <46C098FD.1030601@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Greg KH <gregkh@suse.de>,
	linux-usb-devel@lists.sourceforge.net,
	Andrew Clayton <andrew@digital-domain.net>,
	Paolo Ornati <ornati@fastwebnet.it>, kvm-devel@lists.sourceforge.net,
	Oliver Falk <oliver@linux-kernel.at>,
	Oliver Neukum <oliver@neukum.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	LKML <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>,
	"Stuart_Hayes@Dell.com" <Stuart_Hayes@Dell.com>,
	linux-fsdevel@vger.kernel.org,
	Alan Stern <stern@rowland.harvard.edu>, linux-alpha@vger.kernel.org,
	Tino Keitel <tino.keitel@gmx.de>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Exner <dex@dragonslave.de>,
	Richard Henderson <rth@twiddle.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKeDh-00024E-NY
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 11:00:50 -0700
Received: from nf-out-0910.google.com ([64.233.182.191])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKeDk-00020p-CN
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 11:00:54 -0700
Received: by nf-out-0910.google.com with SMTP id 4so1823164nfv
	for <nfs@lists.sourceforge.net>; Mon, 13 Aug 2007 11:00:51 -0700 (PDT)
In-Reply-To: <46C098FD.1030601@googlemail.com>
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

Here is a list of some known regressions in 2.6.23-rc3.

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



FS

Subject         : [NFSD OOPS] 2.6.23-rc1-git10
References      : http://lkml.org/lkml/2007/8/2/462
Last known good : ?
Submitter       : Andrew Clayton <andrew@digital-domain.net>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



USB

Subject         : EHCI Regression in 2.6.23-rc2
References      : http://lkml.org/lkml/2007/8/10/81
Last known good : ?
Submitter       : Daniel Exner <dex@dragonslave.de>
Caused-By       : Stuart_Hayes@Dell.com <Stuart_Hayes@Dell.com>
                  commit 196705c9bbc03540429b0f7cf9ee35c2f928a534
Handled-By      : ?
Status          : unknown

Subject         : 2.6.23-rc1: USB hard disk broken
References      : http://lkml.org/lkml/2007/7/25/62
Last known good : ?
Submitter       : Tino Keitel <tino.keitel@gmx.de>
Caused-By       : ?
Handled-By      : Oliver Neukum <oliver@neukum.org>
Status          : unknown



Virtualization

Subject         : WARNING: at arch/x86_64/kernel/smp.c:379 smp_call_function_single()
References      : http://lkml.org/lkml/2007/8/10/117
Last known good : ?
Submitter       : Paolo Ornati <ornati@fastwebnet.it>
Caused-By       : Avi Kivity <avi@qumranet.com>
                  commit cec9ad279b66793bee0b5009b7ca311060061efd
Handled-By      : Avi Kivity <avi@qumranet.com>
Status          : problem is being debugged



Alpha

Subject         : -Werror compilation problem - make[1]: *** [arch/alpha/kernel/sys_titan.o] Error 1
References      : http://lkml.org/lkml/2007/8/6/137
Last known good : ?
Submitter       : Oliver Falk <oliver@linux-kernel.at>
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
