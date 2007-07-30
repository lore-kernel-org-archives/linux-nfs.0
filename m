From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 02/23] mount.nfs: fix printf's normally
 hidden	behind NFS_MOUNT_DEBUG
Date: Mon, 30 Jul 2007 07:49:13 -0400
Message-ID: <46ADD039.9070405@RedHat.com>
References: <20070728214918.21871.38740.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFTll-0002rb-DW
	for nfs@lists.sourceforge.net; Mon, 30 Jul 2007 04:50:37 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFTlp-0005Ku-3I
	for nfs@lists.sourceforge.net; Mon, 30 Jul 2007 04:50:41 -0700
In-Reply-To: <20070728214918.21871.38740.stgit@localhost.localdomain>
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

Chuck Lever wrote:
> After I enabled NFS_MOUNT_DEBUG the compiler started spitting out warnings.
> Fix up commas, output formatting, and double-wide character support.
Aren't these debugging statements basically useless because one has to
recompile to turn them on... Wouldn't it make more sense to add
'-o mntdebug' flag so these could be turned on at will?

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
