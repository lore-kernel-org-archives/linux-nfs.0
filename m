From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/4] Introduce sysctl registration helpers
Date: Thu, 3 Aug 2006 15:09:16 +0100
Message-ID: <20060803140916.GA20405@infradead.org>
References: <20060803110537.GA17158@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8dtB-0006qw-Rk
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 07:09:29 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8dtB-0007es-0O
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 07:09:30 -0700
To: Olaf Kirch <okir@suse.de>, viro@parcelfarce.linux.theplanet.co.uk
In-Reply-To: <20060803110537.GA17158@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Aug 03, 2006 at 01:05:37PM +0200, Olaf Kirch wrote:
> Subject: Introduce sysctl registration helpers
> 
> 1/4 register_sysctl_path
> 	This patch introduces a new mechanism for registering a sysctl
> 	table, without having to create those funky dummy tables for
> 	all the parent directories.

Why does this go to the nfs list?  Also have you seen Al's larger sysctl
rework at 

	http://www.kernel.org/git/?p=linux/kernel/git/viro/sysctl.git;a=summary

that includes something similar.

Al, any plans to submit your sysctl rework?


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
