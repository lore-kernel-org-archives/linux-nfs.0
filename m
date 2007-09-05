From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/2] Fix clientaddr= option for text-based NFS
	mounts
Date: Wed, 5 Sep 2007 04:57:26 +0100
Message-ID: <18142.10534.774264.236058@notabene.brown>
References: <20070904201102.4721.77675.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISm1D-0002LW-Oo
	for nfs@lists.sourceforge.net; Tue, 04 Sep 2007 20:57:31 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ISm1H-0000SY-6E
	for nfs@lists.sourceforge.net; Tue, 04 Sep 2007 20:57:36 -0700
In-Reply-To: message from Chuck Lever on Tuesday September 4
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

On Tuesday September 4, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> Please apply these two patches against the latest nfs-utils.  The first patch
> reverts a recent change that made it illegal for a user to specify clientaddr=
> for a text-based NFS mount, and the second clarifies the documentation of the
> clientaddr= option in nfs(5).

Applied.  Sorry for not getting it the first time you posted it - I
was just about to leave for Europe and things were a bit hectic.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
