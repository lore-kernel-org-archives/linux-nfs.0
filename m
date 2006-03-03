From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: ACL on NFS, how make it work?
Date: Fri, 3 Mar 2006 11:35:35 -0500
Message-ID: <20060303163535.GB32552@fieldses.org>
References: <20060303103806.GB8038@sv.lnf.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FFDFo-0003B7-8q
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 08:35:44 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FFDFn-0006mr-W9
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 08:35:44 -0800
To: Marco Gaiarin <gaio@sv.lnf.it>
In-Reply-To: <20060303103806.GB8038@sv.lnf.it>
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

On Fri, Mar 03, 2006 at 11:38:06AM +0100, Marco Gaiarin wrote:
> 
> Sorry for this mail, directly to (as source said ;) nfs3 and nfs4
> kernel developers, but i'm completely stopped trying to make acl work
> via nfs.
...
> There's at least some kernel options, programs, mount switch ... with i
> can debug this?

What filesystems are you exporting, and how are they mounted?  (You
could just post the output of
	mount
and
	exportfs -v
both run on the server.)

Which kernel are you using?

If you're logged in to the server, can you succesfully get and set acls
on the filesystem that you're exporting?

--b.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
