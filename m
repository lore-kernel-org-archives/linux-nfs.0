From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [PATCH] unfsd: fix invalid argument error for
	setattr	request
Date: Tue, 21 Aug 2007 08:45:53 +0200
Message-ID: <20070821064553.GA16576@uio.no>
References: <Pine.LNX.4.64.0708160843060.10107@maggie.lkpg.cendio.se>
	<200708160751.AA00238@paprika.lab.ntt.co.jp>
	<20070816133350.GB9941@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter_Astrand <astrand@cendio.se>, nfs@lists.sourceforge.net,
	Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INNV6-0003IK-KF
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 23:46:20 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1INNV8-0006W1-KX
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 23:46:09 -0700
In-Reply-To: <20070816133350.GB9941@fieldses.org>
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

On Thu, Aug 16, 2007 at 09:33:50AM -0400, J. Bruce Fields wrote:
> Have you tried the debian bug-tracking system?  Maybe they're
> practically speaking the only maintainers that unfsd has now.

FWIW, mail to the bug tracking system goes to the same e-mail as the one in
the Maintainer: field in the package.

As maintainer of the current nfs-utils packages (including nfs-kernel-server)
I'd be happy to see nfs-user-server go away from Debian as well, but I've
spoken to the maintainer in the past and he seemed unwilling to let it go.
Don't ask me why.

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
