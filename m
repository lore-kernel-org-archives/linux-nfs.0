From: Andrew Clayton <andrew@digital-domain.net>
Subject: Re: [NFSD OOPS] 2.6.23-rc1-git10
Date: Fri, 3 Aug 2007 09:27:52 +0100
Message-ID: <20070803092752.51e74f8c@zeus.pccl.info>
References: <20070802171450.7c9b4af3@zeus.pccl.info>
	<18098.42691.783443.554197@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGsVn-00072w-F0
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 01:27:55 -0700
Received: from smtp.aaisp.net.uk ([81.187.81.52])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGsVq-0006rF-7m
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 01:27:59 -0700
In-Reply-To: <18098.42691.783443.554197@notabene.brown>
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

On Fri, 3 Aug 2007 13:53:39 +1000, Neil Brown wrote:

[snip]

> So clearly we need some proper locking around thread start-up and
> shutdown.  We had previous relied on lock_kernel, but that isn't
> really good enough for this.   I'll try to figure out the best way to
> fix it.  Meanwhile, I doubt the problem will recur.
> 
> Thanks for the report.

Thanks for the explanation!

> NeilBrown

Andrew

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
