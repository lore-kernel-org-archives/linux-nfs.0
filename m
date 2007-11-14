From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [PATCH 00/25] RFC: AF_INET6 family support for the
	NFS	client
Date: Wed, 14 Nov 2007 10:19:05 +0100
Message-ID: <20071114091905.GB23499@uio.no>
References: <20071113182226.5087.77009.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsEOz-0001pa-Dy
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 01:19:17 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsEP0-0000ZU-AD
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 01:19:19 -0800
In-Reply-To: <20071113182226.5087.77009.stgit@manray.1015granger.net>
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

On Tue, Nov 13, 2007 at 01:30:59PM -0500, Chuck Lever wrote:
> These 25 patches add support for AF_INET6 addresses to the NFS client.
> This is a request for review of the proposed changes.
> 
> This series does not add support for AF_INET6 addresses to the Linux
> NLM or NSM implementations, nor does it add support in the NFS server.

This is awesome. I can't wait for the server support :-)

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
