From: walt <wa1ter@myrealbox.com>
Subject: Re: NFS (version 2) breakage from recent commit
Date: Thu, 12 Jan 2006 07:37:38 -0800
Message-ID: <dq5t42$pim$1@sea.gmane.org>
References: <dq35hi$372$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ex4Wt-0002p2-4a
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 07:38:23 -0800
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ex4Wr-0007T7-II
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 07:38:22 -0800
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Ex4WS-0006Oq-OK
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 16:37:57 +0100
Received: from adsl-69-234-210-171.dsl.irvnca.pacbell.net ([69.234.210.171])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 12 Jan 2006 16:37:56 +0100
Received: from wa1ter by adsl-69-234-210-171.dsl.irvnca.pacbell.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 12 Jan 2006 16:37:56 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <dq35hi$372$1@sea.gmane.org>
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

walt wrote:
> Hi all,
> 
[...]
> #mount -t nfs k2:/ /mnt/nfs/
> mount: Cannot allocate memory

I just discovered that only version 2 is broken -- NFS v3
works fine.



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
