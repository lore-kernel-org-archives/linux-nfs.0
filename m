From: Tobias Diedrich <ranma@tdiedrich.de>
Subject: Re: NFSv3, 2.6, ext3 and dir_index
Date: Sun, 20 Mar 2005 22:21:06 +0100
Message-ID: <20050320212106.GA5580@yamamaya.is-a-geek.org>
References: <20050120163806.GA25242@melchior.yamamaya.is-a-geek.org> <20050314172234.GA11469@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sf.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DD7rK-0005Ip-OL
	for nfs@lists.sourceforge.net; Sun, 20 Mar 2005 13:21:18 -0800
Received: from lum.tdiedrich.de ([193.24.211.71] ident=postfix)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DD7rH-0004Fz-7N
	for nfs@lists.sourceforge.net; Sun, 20 Mar 2005 13:21:18 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20050314172234.GA11469@perlsupport.com>
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

Sorry for the late reply.

Chip Salzenberg wrote:

> Did you ever get any replies on dir_index vs. nfs?

Not really.

> I'm just setting up a new server and I'm wondering if there's
> something still out there that might make me sorry to use dir_index.

For now I've just disabled dir_index and I haven't had any problems
since, but I'm not completely sure if that really was the cause of
the problem I was seeing.  At least disabling dir_index is rather
easy (remove dir_index featureflag with tune2fs and run e2fsck to
get rid of the remaining hashtrees).
Maybe I'll try again to get a proper traffic trace, but I guess I'd
have to set up a test client first to separate the unrelated nfs traffic.

-- 
Tobias						PGP: http://9ac7e0bc.uguu.de


-------------------------------------------------------
This SF.net email is sponsored by Microsoft Mobile & Embedded DevCon 2005
Attend MEDC 2005 May 9-12 in Vegas. Learn more about the latest Windows
Embedded(r) & Windows Mobile(tm) platforms, applications & content.  Register
by 3/29 & save $300 http://ads.osdn.com/?ad_id=6883&alloc_id=15149&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
