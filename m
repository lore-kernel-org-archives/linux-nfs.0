From: Suresh Jayaraman <sjayaraman@novell.com>
Subject: Re: Differences between 2.6.5 und 2.6.16: getattr with
 actimeo=0 and O_DIRECT
Date: Tue, 13 Nov 2007 16:19:08 +0530
Message-ID: <47398124.6070708@novell.com>
References: <4739686E.8080501@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Gerd Bavendiek <gerd.bavendiek@googlemail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IrtF7-000778-QY
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 02:43:42 -0800
Received: from victor.provo.novell.com ([137.65.250.26])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IrtFC-0000Pa-II
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 02:43:47 -0800
In-Reply-To: <4739686E.8080501@googlemail.com>
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

Gerd Bavendiek wrote:

> 
> analyzing performance issues with Oracle databases on an NFS client
> running on SLES9 SP3 and NetApp as NFS server, I found that in SLES9
> SP3 each write call is followed by an getattr. This is not the case
> with SLES10 SP1.

The changes between 2.6.5 and 2.6.16 are too many that it is not easy to
track down.

> I do
> 
> dd if=/dev/zero of=/mnt/qqq oflag=direct bs=8k count=100000
> 
> and using tcpdump (BTW, is there an easier way ?) I see with SLES9 SP3
> (i.e. 2.6.5-7.244) each single 8k write followed by an getattr (which
> comes at some cost).

I Would suggest trying the latest kernel update from Novell/SUSE.

If the issue is seen in the latest kernels, create a bug report in
Novell/SUSE bugzilla - https://bugzilla.novell.com

Thanks,
-- 
Suresh Jayaraman

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
