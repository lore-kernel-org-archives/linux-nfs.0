From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: [PATCH] mount.nfs: Update description of clientaddr= in
 nfs(5)
Date: Fri, 31 Aug 2007 02:12:23 +0200
Message-ID: <46D75CE7.2020605@oxeva.fr>
References: <20070830194810.4524.58037.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQu7g-0000UQ-NX
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 17:12:31 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQu7j-0003NM-ES
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 17:12:33 -0700
In-Reply-To: <20070830194810.4524.58037.stgit@monet.1015granger.net>
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

On 08/30/2007 9:48:10 PM +0200, Chuck Lever <chuck.lever@oracle.com> wrote:
> The description of clientaddr= in nfs(5) is out of date and omits some
> other typical reasons for using it.  Let's start with this rewrite.
> 

By the way, can we update the man page date show the current version 
somewhere ? This is a bit disturbing to see "20 November 1993" at the 
bottom of the man page, and would clear minds about the "ignored at this 
time" or "not implemented yet" : does the word "currently" makes any 
sense, when the only date showed is 15 years ago ?

Gabriel

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
