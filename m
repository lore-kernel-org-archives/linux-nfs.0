From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 00/29] IPv6 for NFS client
Date: Thu, 29 Nov 2007 14:39:50 -0500
Message-ID: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpFw-0001RU-Ex
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:04 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpG0-0007SM-Ff
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:10 -0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Oh boy! Another big patch set from Chuck!

Here's a set of patches that add support for AF_INET6 addresses to
Linux's in-kernel NFS client (not the mount command, NLM/NSM, or
rpcbind).  These are a pre-requisite for full IPv6 support for Linux's
NFS implementation.

These are similar to the set I sent two weeks ago, with some clean-ups.
The clean-ups mostly reduce the number of explicit type casts we're left
with at the end of the series, to make things easier to read.

Some testing with NFSv3 and NFSv4 using IPv4 addresses has been done to
verify that IPv4 isn't broken (badly) by these changes.  Support for IPv6
in the new text-based mount command is still under construction, and will
be along soon.

I think these are ready to consider for 2.6.25.

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

