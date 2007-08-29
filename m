From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: fix length
	computation	in	nfs_validate_mount_data
Date: Wed, 29 Aug 2007 17:10:26 -0400
Message-ID: <1188421826.6580.136.camel@heimdal.trondhjem.org>
References: <Pine.LNX.4.64.0708291509500.2779@jlentini-linux.nane.netapp.com>
	<46D5D774.20908@oracle.com>
	<1188420008.6580.126.camel@heimdal.trondhjem.org>
	<46D5DFBE.6030506@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQUo4-0006wO-QD
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:10:38 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQUo7-0000xQ-Qt
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:10:37 -0700
In-Reply-To: <46D5DFBE.6030506@oracle.com>
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

On Wed, 2007-08-29 at 17:06 -0400, Chuck Lever wrote:

> These are not just clean-ups.  They really are bug-fixes for the API. 
> I'm sorry I didn't recognize the semantic distinction in the patch 
> description.
> 
> As Tom said, these really are needed to make the interface useful.

Could you in that case, please correct the changelog entries (pointing
out exactly which bugs/interface flaws are being fixed), and resend.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
