From: Chris Caputo <ccaputo@alt.net>
Subject: Re: cache/mmap()/server coherency problems
Date: Wed, 15 Jan 2003 09:43:14 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0301150937580.28761-100000@nacho.alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nacho.alt.net ([207.14.113.18])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YrZn-0001SP-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 09:43:43 -0800
To: nfs@lists.sourceforge.net
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

Just to follow-up on this thread...  I had some additional emails with
Trond on this and it turns out the problem is that in 2.4 one process can
mmap() a page in a file such that it is in effect pinned in the page cache
and it won't be updated, even after it is munmap()ed.  He suggested this
may be better in 2.5 but I haven't checked.

My workaround is to not mmap() pages that are partially filled in files
that I expect to grow.  This appears to be working fine.

Chris



-------------------------------------------------------
This SF.NET email is sponsored by: A Thawte Code Signing Certificate 
is essential in establishing user confidence by providing assurance of 
authenticity and code integrity. Download our Free Code Signing guide:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0028en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
