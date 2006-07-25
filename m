From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: [PATCH 002 of 9] knfsd: knfsd: Remove an unused variable
	from e_show().
Date: Tue, 25 Jul 2006 00:10:59 -0400
Message-ID: <20060725041059.GA13294@filer.fsl.cs.sunysb.edu>
References: <20060725114207.21779.patches@notabene>
	<1060725015432.21921@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5EGC-0007A2-HB
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 21:11:08 -0700
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5EGA-0008Ai-Kt
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 21:11:09 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060725015432.21921@suse.de>
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

On Tue, Jul 25, 2006 at 11:54:32AM +1000, NeilBrown wrote:
...
> diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
> --- .prev/fs/nfsd/export.c	2006-07-24 14:33:06.000000000 +1000
> +++ ./fs/nfsd/export.c	2006-07-24 14:33:26.000000000 +1000
> @@ -1178,7 +1178,6 @@ static int e_show(struct seq_file *m, vo
...
>  	if (p == (void *)1) {

I'm not an NFS expert, but the above makes me want to puke. Isn't there a
cleaner way of doing whatever needs to be done without:

1) hard-coding a constant
2) comparing a variable to an arbitrary pointer

Josef Sipek.

-- 
If I have trouble installing Linux, something is wrong. Very wrong.
		- Linus Torvalds

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
