From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Enable logs
Date: Sat, 20 Oct 2007 20:24:02 -0400
Message-ID: <1192926242.7505.3.camel@heimdal.trondhjem.org>
References: <200710201213.27120.grungadeben@fuckaround.org>
	<1192903956.7440.18.camel@heimdal.trondhjem.org>
	<200710202247.56443.grungadeben@fuckaround.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Pol Hallen <grungadeben@fuckaround.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IjObv-0004dX-Az
	for nfs@lists.sourceforge.net; Sat, 20 Oct 2007 17:24:07 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IjObz-0007GS-A2
	for nfs@lists.sourceforge.net; Sat, 20 Oct 2007 17:24:12 -0700
In-Reply-To: <200710202247.56443.grungadeben@fuckaround.org>
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


On Sat, 2007-10-20 at 22:47 +0200, Pol Hallen wrote:
> > I'm not sure I understand what you mean. Logging of what exactly?
> When a client connect to server, how many time stay connected, which files 
> use, etc.
> 
> Pol

Sorry, but that isn't supported. It isn't even possible in the case of
NFS-over-UDP.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
