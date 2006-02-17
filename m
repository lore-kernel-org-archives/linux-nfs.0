From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS lock reclaiming not working on SLES9 SP2
Date: Fri, 17 Feb 2006 10:25:55 +0100
Message-ID: <20060217092555.GA25707@suse.de>
References: <20060217044448.16069.qmail@webmail34.rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FA1sH-00032V-QG
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 01:26:01 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FA1sG-00036G-Bb
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 01:26:01 -0800
To: asha yr <asha_yr@rediffmail.com>
In-Reply-To: <20060217044448.16069.qmail@webmail34.rediffmail.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

On Fri, Feb 17, 2006 at 04:44:48AM -0000, asha  yr wrote:
> The reclaiming of locks was working fine on base SLES9. It started failing after I updated SLES9 with SP2.

Did you try SLES9 SP3? I remember we had some problems with lock reclaim,
but I thought they were fixed in SP2.

It would be useful to get a lockd trace on the server side, what it
receives and what it sends back. The ethereal traces aren't very useful
though; it seems the snaplen is too small (and binary dumps are usually
much more helpful than the "helpful" ASCII packet representation that
ethereal or tcpdump generate)

Thanks,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
