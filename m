From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/4] A handful of mount.nfs clean up patches
Date: Fri, 24 Aug 2007 13:16:08 +1000
Message-ID: <18126.19832.907893.895307@notabene.brown>
References: <20070821161749.4373.16685.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOPeg-0000bs-EQ
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 20:16:14 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IOPej-0001Oc-Ca
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 20:16:18 -0700
In-Reply-To: message from Chuck Lever on Tuesday August 21
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

On Tuesday August 21, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> Here's a handful of minor clean-ups for mount.nfs.  These precede some more
> complex changes to the text-based mount handling logic; I'm breaking the
> series up to make review easier.

Thanks.  They are in .git (with some changes to the first, as I
mentioned).

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
