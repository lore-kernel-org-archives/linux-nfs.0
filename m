From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: cp: getting attribute `system.nfs4_acl' Operation not
	supported
Date: Thu, 4 Jan 2007 17:08:54 -0500
Message-ID: <20070104220854.GC2216@fieldses.org>
References: <C1C2D3EA.28C7%rsalmon@tulane.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2alc-0002hO-MP
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 14:08:56 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2ald-0000US-3W
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 14:08:58 -0800
To: Rene Salmon <rsalmon@tulane.edu>
In-Reply-To: <C1C2D3EA.28C7%rsalmon@tulane.edu>
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

On Thu, Jan 04, 2007 at 03:55:22PM -0600, Rene Salmon wrote:
> Hi list,
> 
> I am getting this message when I try to do a cp on an nfsv4 mounted file
> system:
> 
> cp: getting attribute `system.nfs4_acl' of
> `rsalmon/test-q/single-cpu/ForRene.f': Operation not supported
> 
> I found one thread in the list archives about this:
> http://linux-nfs.org/pipermail/nfsv4/2006-February/003518.html
> 
> >From the thread it looks like this was already fixed.  I am running kernel
> 2.9.16.29.  Any ideas as to if this kernel contains this fix?

The fix is in 2.6.17.  I don't know if it went into the 2.6.16.x
series--I doubt it.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
