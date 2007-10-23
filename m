From: Kumar Gala <galak@kernel.crashing.org>
Subject: LTP ustat01 test fails on NFSROOT
Date: Tue, 23 Oct 2007 17:52:44 -0500
Message-ID: <CBDE987B-0713-4D62-8122-054183E75410@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkSbT-0000qe-Av
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 15:52:03 -0700
Received: from gate.crashing.org ([63.228.1.57]
	ident=[U2FsdGVkX1+Y5RXyHT48r41kLXskRtvMxthfyYlIBfY=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IkSbY-00079Z-IP
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 15:52:08 -0700
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

I'm looking into an issue with LTP's ustat01 & ustat02 tests in which  
they report the following:

ustat01     1  FAIL  :  ustat(2) failed and setthe errno to 116 :  
Stale NFS file handle
ustat02     2  FAIL  :  ustat(2) failed to produce expected error;  
14, errno: EFAULT and got 116

It appears sometime between 2.6.21 and 2.6.22-rc1 some changes to NFS  
got introduced that cause this.

was wondering about any ideas while I try to debug what's going on.

thanks

- k

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
