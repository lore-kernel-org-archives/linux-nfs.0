From: Olaf Kirch <okir@suse.de>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: Sat, 27 Sep 2003 18:55:04 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030927165504.GB5316@suse.de>
References: <16243.34641.819894.763746@charged.uio.no> <200309261831.h8QIVNVw026806@buggy.badula.org> <16244.48596.850187.268449@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Ion Badulescu <lists@news.cs.columbia.edu>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A3Iaw-00064j-00
	for <nfs@lists.sourceforge.net>; Sat, 27 Sep 2003 10:10:58 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A3Iaw-0007TI-08
	for nfs@lists.sourceforge.net; Sat, 27 Sep 2003 10:10:58 -0700
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

On Fri, Sep 26, 2003 at 03:29:40PM -0700, Trond Myklebust wrote:
>      > Not that the current situation is any better, of course.
> 
>      > Perhaps making that wait an uninterruptable wait would be
>      > enough to take care of the problem?
> 
> People expect the "intr" flag to work if they set it.

In this case, not removing the sillyrenamed file instead
of oopsing may be the preferred action.

Olaf
-- 
Olaf Kirch     |  Anyone who has had to work with X.509 has probably
okir@suse.de   |  experienced what can best be described as
---------------+  ISO water torture. -- Peter Gutmann


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
