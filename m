From: Ion Badulescu <lists@news.cs.columbia.edu>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: Mon, 29 Sep 2003 08:07:15 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309290757580.21173-100000@guppy.limebrokerage.com>
References: <16244.48596.850187.268449@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A3wtV-00010a-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Sep 2003 05:12:49 -0700
Received: from algx-tower-com-4173.z188-2-66.customer.algx.net ([66.2.188.62] helo=ns1.limegroup.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A3wtT-0003qT-Mg
	for nfs@lists.sourceforge.net; Mon, 29 Sep 2003 05:12:47 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <16244.48596.850187.268449@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, 26 Sep 2003, Trond Myklebust wrote:

>      > Perhaps making that wait an uninterruptable wait would be
>      > enough to take care of the problem?
> 
> People expect the "intr" flag to work if they set it.

People also expect the supported "intr" flag not to cause security 
problems and would gladly take an unkillable process over a kernel oops...

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
