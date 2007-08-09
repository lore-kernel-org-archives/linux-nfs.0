From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [PATCH 10/10] mount.nfs: Fix background mounts
Date: Thu, 9 Aug 2007 21:16:06 +0200
Message-ID: <20070809191606.GA5007@uio.no>
References: <20070803172415.3357.91411.stgit@monet.1015granger.net>
	<20070806223152.GA7917@uio.no>
	<18103.46593.586196.718154@notabene.brown>
	<46B7BD61.7060304@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJDUU-0000Nb-J6
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 12:16:14 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJDUW-00042I-Dr
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 12:16:18 -0700
In-Reply-To: <46B7BD61.7060304@oracle.com>
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

On Mon, Aug 06, 2007 at 08:31:29PM -0400, Chuck Lever wrote:
> Steinar, it's not clear to me from the Debian bug report whether this is 
> really a mount bug or an init scripts bug.

To me neither, unfortunately. The bug is something like five years old :-)
(If the code hasn't changed, I doubt it has magically fixed itself, though.)

> I assume this is something that did not work correctly for the legacy
> util-linux mount command either?

It's from way before mount was moved to nfs-utils.

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
