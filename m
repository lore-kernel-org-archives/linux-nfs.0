From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read Only
Date: Wed, 20 Oct 2004 10:44:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098261880.5390.6.camel@lade.trondhjem.org>
References: <ffdf9394041019184357ee0394@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKC5j-00049Q-OR
	for nfs@lists.sourceforge.net; Wed, 20 Oct 2004 01:45:07 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CKC5i-0003eM-80
	for nfs@lists.sourceforge.net; Wed, 20 Oct 2004 01:45:07 -0700
To: Tiago Giovanaz da Silva <tiagogiovanaz@gmail.com>
In-Reply-To: <ffdf9394041019184357ee0394@mail.gmail.com>
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

ty den 19.10.2004 Klokka 22:43 (-0300) skreiv Tiago Giovanaz da Silva:
> Hello all!
> How to I make for two people not to obtain to use the same archive at
> the same time?
> For example, with samba, two users can't write in the same file at the
> same time.

Short answer: You can't

long answer: Use of advisory POSIX locks (man fcntl) or lock files (see
the NFS FAQ) will do what you want _if_ all the programs that access the
same file use the same locking scheme (that's why they are called
"advisory locks" as opposed to "mandatory locks").

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
