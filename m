From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: ACL patch - is this bad or good?
Date: Mon, 6 Dec 2004 11:30:54 +1100
Message-ID: <16819.43070.634276.944461@cse.unsw.edu.au>
References: <20041204222659.GA5837@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cb6n1-0006Iy-If
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 16:31:43 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cb6mv-00028t-Jt
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 16:31:39 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Saturday December 4
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

On Saturday December 4, chip@pobox.com wrote:
> Hi there.  A Debian user contributed a copy of what he says is a Red
> Hat patch to support "acl" and "no_acl" options for NFS exports.
> 
> Is this patch OK?

Define "OK" ???

I must admit a personal bias.  I find it very hard to get enthusiastic
about anything relating to ACLs.   I think they are one of the worst
mis-features ever to be grafted on to the side of a filesystem.

I am *very* tempted to say "Don't use an old client if your server
supports ACLs", but there are probably some poor souls out there who
are forced to do so due to circumstances beyond their control......

This patch is OK as far as it goes.  However it is completely useless
against a kernel.org kernel as support for NFSEXP_NOACL hasn't been
merged yet.

But I suspect it will be if anyone bothers to pester me about it .....

So I am OK with this patch going in to nfs-utils, providing the man
page make it clear that not all kernels support this functionality,
and will quietly accept but ignore the flag.

Anyone want to re-make the patch with a suitable change to the
manpage?

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
