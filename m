From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/9] mount.nfs: Fix nfs4mount_s prototype.
Date: Sat, 25 Aug 2007 08:08:34 +1000
Message-ID: <18127.22242.307898.761934@notabene.brown>
References: <20070824171111.10418.69889.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOhKe-0008Re-AG
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 15:08:44 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IOhKg-0002s6-C6
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 15:08:48 -0700
In-Reply-To: message from Chuck Lever on Friday August 24
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

> @@ -286,13 +287,13 @@ fail:
>   * @extra_opts:	pointer to C string containing fs-specific mount options
>   *		(possibly also a return argument)
>   * @fake:	flag indicating whether to carry out the whole operation
> - * @bg:		one if this is a backgrounded mount attempt
> + * @child:	one if this is a backgrounded mount

Any reason for changing 'bg' to 'child'?
And not making a matching change in nfsmount_s?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
