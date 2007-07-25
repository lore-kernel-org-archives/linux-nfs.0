From: Rick Macklem <rick@snowhite.cis.uoguelph.ca>
Subject: Re: [PATCH] NFS: have string-based mount options default to
	intr mounts
Date: Wed, 25 Jul 2007 16:05:50 -0400 (EDT)
Message-ID: <200707252005.QAA25492@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	jlayton@redhat.com
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDn6E-0008Ir-74
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 13:04:47 -0700
Received: from gigi.cs.uoguelph.ca ([131.104.94.210])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDn6G-0000sz-SD
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 13:04:49 -0700
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

> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> > I thought "nointr" was the default because it is safest.
> > 

I was actually impressed that "intr" mounts work for NFSv4. I would have
thought interrupting an RPC that has state related (Open, Lock,...) op(s)
in it would cause grief later. (NFSERR_BADSEQID or similar)

Do you spin off kernel threads to babysit those outstanding RPCs? rick

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
