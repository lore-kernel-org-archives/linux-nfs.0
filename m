From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] knfsd: Tidyup up meaning of 'buffer size' in
	nfsd/sunrpc
Date: Fri, 6 Oct 2006 18:06:33 -0400
Message-ID: <20061006220633.GE18026@fieldses.org>
References: <20061005171043.4544.patches@notabene> <1061005071212.6527@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVxq9-0001dL-Bg
	for nfs@lists.sourceforge.net; Fri, 06 Oct 2006 15:06:45 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVxq9-0003ul-0D
	for nfs@lists.sourceforge.net; Fri, 06 Oct 2006 15:06:46 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1061005071212.6527@suse.de>
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

On Thu, Oct 05, 2006 at 05:12:12PM +1000, NeilBrown wrote:
> Ok, this patch should fix up the remaining issue with a recent
> set of NFSD patches.  It has been reviewed by Greg, and I'm convinced:-)

It's working for me, thanks.--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
