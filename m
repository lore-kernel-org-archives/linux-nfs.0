From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Live performance tools?
Date: Tue, 14 Aug 2007 23:48:29 +0200
Message-ID: <20070814214829.GA9996@uio.no>
References: <slrnfc1j28.fcc.jgoerzen@katherina.lan.complete.org>
	<46C1E8E8.3060405@ilm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IL4Fd-0004ZE-C7
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 14:48:33 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IL4Fg-0003CH-CW
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 14:48:37 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA:32)
	(Exim 4.50) id 1IL4Fa-0004yu-Eo
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 23:48:30 +0200
Received: from root by trofast.sesse.net with local (Exim 4.67)
	(envelope-from <sesse@samfundet.no>) id 1IL4FZ-0002fJ-TH
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 23:48:29 +0200
In-Reply-To: <46C1E8E8.3060405@ilm.com>
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

On Tue, Aug 14, 2007 at 10:39:52AM -0700, Eli Stair wrote:
> You could also start up inotify on the linux NFS server, watching the 
> entire directory tree you're exporting via NFS, log the output, and 
> later analyze the file ops as reported.

blktrace might also be useful here.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
