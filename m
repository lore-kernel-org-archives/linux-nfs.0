From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: ACL on NFS, how make it work?
Date: Thu, 9 Mar 2006 09:00:02 -0500
Message-ID: <20060309140002.GB1093@fieldses.org>
References: <20060303103806.GB8038@sv.lnf.it> <20060308170425.GS8060@sv.lnf.it> <20060309014955.GA8089@fieldses.org> <200603090056.31041.gopal@nerur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Marco Gaiarin <gaio@sv.lnf.it>,
	Andreas Gruenbacher <agruen@suse.de>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHLgY-0000YY-7A
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 06:00:10 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHLgU-00088P-51
	for nfs@lists.sourceforge.net; Thu, 09 Mar 2006 06:00:10 -0800
To: Gopal Santhanam <gopal@nerur.com>
In-Reply-To: <200603090056.31041.gopal@nerur.com>
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

On Thu, Mar 09, 2006 at 12:56:30AM -0800, Gopal Santhanam wrote:
> It seems to work for me.  Thanks!
> 
> Why does the return value of vfs_getxattr change between the two 
> calls though?  Can you explain?

Well, it *could* happen just by accident if someone was modifying the
acl simultaneously with our fetching it.  Obviously that wasn't
happening in this case, though.

Looks to me like a bug in XFS.  Though in practice, since the return
value is expected to be used just to guess at the correct buffer size,
returning a too-large size probably isn't a problem for most
applications.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
