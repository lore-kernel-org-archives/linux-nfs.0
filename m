From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: ACL on NFS, how make it work?
Date: Mon, 6 Mar 2006 10:23:40 -0500
Message-ID: <20060306152340.GA31408@fieldses.org>
References: <20060303103806.GB8038@sv.lnf.it> <20060303163535.GB32552@fieldses.org> <20060306090557.GD8429@sv.lnf.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGHYs-0008KO-5i
	for nfs@lists.sourceforge.net; Mon, 06 Mar 2006 07:23:50 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FGHYq-0005tX-T7
	for nfs@lists.sourceforge.net; Mon, 06 Mar 2006 07:23:50 -0800
To: Marco Gaiarin <gaio@sv.lnf.it>
In-Reply-To: <20060306090557.GD8429@sv.lnf.it>
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

On Mon, Mar 06, 2006 at 10:05:57AM +0100, Marco Gaiarin wrote:
> Apart /home (via autofs), i export /srv to clients. Both, as you can
> see, are XFS ACL-enabled filesystem:

Actually I got one other NFS/XFS ACL complaint recently, and confirmed
that with current kernels I'm able to get and set ext3 ACL's over NFS,
and get and set XFS ACL's locally, but I can't use XFS ACL's over NFS.
Which is odd--on a first glance it looks like the two filesystems export
posix acl's through the same interface, etc.  I haven't had the chance
to figure out what's going on yet....

--b.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
