From: Ilya Ovchinnikov <ilya@prao.ru>
Subject: Re: BUG: TIFF files created by libtiff on NFS4 filesystem are
 corrupted
Date: Tue, 06 Nov 2007 22:11:24 +0300
Message-ID: <4730BC5C.2050405@prao.ru>
References: <47306586.6050802@prao.ru>
	<1194368052.17476.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexandr Zaitsev <sasha-z@psn.ru>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpTpl-0004iF-6B
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 11:11:33 -0800
Received: from server.psn.ru ([194.149.67.134])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IpTpo-00011M-LC
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 11:11:38 -0800
In-Reply-To: <1194368052.17476.8.camel@heimdal.trondhjem.org>
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

Trond Myklebust wrote:
> 
> Known issue with 2.6.23.
> 
> See http://bugzilla.kernel.org/show_bug.cgi?id=9315
> 
> Cheers
>   Trond

The patch from http://bugzilla.kernel.org/show_bug.cgi?id=9315 solves 
the problem, thank you!

With best regards,
Ilya Ovchinnikov

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
