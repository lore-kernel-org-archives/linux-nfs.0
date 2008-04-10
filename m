From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: nfs4_getfacl "Failed getxattr operation" when too many ACL
 entries exist
Date: Thu, 10 Apr 2008 18:41:18 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0804101837200.12362@citi.umich.edu>
References: <47FE8C68.50502@csupomona.edu> <Pine.BSO.4.64.0804101829270.12362@citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Brian De Wolf <bldewolf@csupomona.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:35411 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbYDJWlT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Apr 2008 18:41:19 -0400
In-Reply-To: <Pine.BSO.4.64.0804101829270.12362@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Apr 2008, david m. richter wrote:

> On Thu, 10 Apr 2008, Brian De Wolf wrote:
> 
> > Recently we've been prototyping serving Solaris ZFS exports via NFSv4 to some
> > Linux hosts.  These will some day be exposed to general users, so I've been
> > testing things to see if I can break them.  Anyway, it seems that nfs4_getfacl
> > is only able to read ACLs with up to 208 entries.  nfs4_setfacl is able to
> > insert a 209th entry, but any attempts to view or edit the ACLs after that
> > fail with:
> > 
> > Failed getxattr operation
> > : Input/output error
> > 
> > There are two ways to make the ACLs readable again:
> > 1) Have someone log in to the Solaris box and remove some of the entries
> > 2) Reset the ACLs using nfs4_setfacl -s `some spec`
> > 
> > Has anyone run into this issue before?  Is it fixable?  I didn't reach the
> > same problem locally on the Solaris box, nor on another Solaris box with the
> > same NFS mount, so it looks like it's a problem specific to Linux.  Here's the
> > versions of relevant packages on the test box running Gentoo (did I miss
> > any?):
> > Kernel: 2.6.23-gentoo-r8
> > nfs-utils-1.1.0-r1
> > attr-2.4.39
> > nfs4-acl-tools-0.3.2
> 
> 	honestly, this probably stems from some naive, unrevisited <ahem> 
> assumptions still lingering nfs4-acl-tools code that need fixing.  at the 
> -very- least, nfs4_setfacl could save the original ACL and attempt to 
> restore it if the setxattr() call fails.

	sorry, misread part of your letter the first time around -- it'd 
be very bizarre if nfs4_getfacl influenced the ACL in any way, so i 
suspect that something's going awry with nfs4_setfacl.  seeing such an 
arbitrary limit of 208 or 209 ACEs looks like the tools being dumb.

	d
	.
 
> 	it's possible this case involves the server, but i suspect the 
> tools.  i'll look at this tomorrow and get back to you.
> 
> 
> 	d
> 	.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
