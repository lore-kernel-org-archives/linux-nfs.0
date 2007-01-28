From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: question about fh_copy
Date: Sun, 28 Jan 2007 18:01:48 -0500
Message-ID: <20070128230148.GB12125@fieldses.org>
References: <1169911208.2767.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Ming Zhang <blackmagic02881@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBJ1z-0003bk-0F
	for nfs@lists.sourceforge.net; Sun, 28 Jan 2007 15:01:51 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBJ1z-00012O-L2
	for nfs@lists.sourceforge.net; Sun, 28 Jan 2007 15:01:52 -0800
In-Reply-To: <1169911208.2767.15.camel@localhost.localdomain>
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

On Sat, Jan 27, 2007 at 10:20:08AM -0500, Ming Zhang wrote:
> A question about fh_copy(). This function is called many times on
> argument passed directly from nfs clients. If a malicious nfs client
> forge a fh, then fh_copy can invoke oops quite easily.

I don't see how; can you explain?

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
