From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH kNFSd 0 of 16] Introduction
Date: Mon, 21 Mar 2005 22:50:59 -0800
Message-ID: <20050321225059.05dc503b.akpm@osdl.org>
References: <20050322163830.8762.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDdEY-0001Js-Vx
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 22:51:22 -0800
Received: from fire.osdl.org ([65.172.181.4] helo=smtp.osdl.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DDdEW-0003mD-Cd
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 22:51:22 -0800
To: NeilBrown <neilb@cse.unsw.edu.au>
In-Reply-To: <20050322163830.8762.patches@notabene>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

NeilBrown <neilb@cse.unsw.edu.au> wrote:
>
>  Following are 16 patches against nfsd in 2.6.12-rc1-mm1
> 
>  Most are nfsv4 related.
>  Patch 2 removes an inexplicable increment of f_count for a file.  This 
>  fixes a problem wherein an exported filesystem may never be unmountable because a
>  file on it is never closed.

OK, I'll send nlm-fix-f_count-leak.patch in for 2.6.12 and will buffer the
rest.

>  This could possibly be a candidate for 2.6.12.  The rest should wait to go 
>  in to 2.6.13-rc

Is it a 2.6.11.x candidate?


-------------------------------------------------------
This SF.net email is sponsored by Microsoft Mobile & Embedded DevCon 2005
Attend MEDC 2005 May 9-12 in Vegas. Learn more about the latest Windows
Embedded(r) & Windows Mobile(tm) platforms, applications & content.  Register
by 3/29 & save $300 http://ads.osdn.com/?ad_id=6883&alloc_id=15149&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
