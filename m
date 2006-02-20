From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS lock reclaiming not working on Redhat4 update3
Date: Mon, 20 Feb 2006 13:54:31 -0500
Message-ID: <43FA1067.3070506@RedHat.com>
References: <20060217110240.19279.qmail@webmail33.rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBGBD-0003CV-Hb
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 10:54:39 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FBGBC-0000QQ-FC
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 10:54:39 -0800
To: asha yr <asha_yr@rediffmail.com>
In-Reply-To: <20060217110240.19279.qmail@webmail33.rediffmail.com>
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

asha yr wrote:
> NFS lock reclaiming is not working on Redhat4 Update3.
I opened up the following bz report to trace this problem:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=182137.
The proposed patch in in that bz report.

steved.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
