From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS lock recovery problem if subtree_check option used
Date: Fri, 19 Nov 2004 10:18:16 -0500
Message-ID: <1100877496.11263.9.camel@lade.trondhjem.org>
References: <20041119111003.52425.qmail@web51607.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20041119111003.52425.qmail@web51607.mail.yahoo.com>
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

fr den 19.11.2004 Klokka 03:10 (-0800) skreiv mehta kiran:
> Hi , 
>      I am facing new problem in NFS lock krecovery
>       on sles9 sp1 beta2 release.
>      This problem was not there in slses9 rc5 
>      release.
> PROBLEM:
> 
> NFS stale handle error if client tries to reclaim lock
> for filesystem exported with subtree_check option

That is a known server bug, and is not just limited to locks. Neil
committed the following fix to Bitkeeper not too long ago.

http://linux.bkbits.net:8080/linux-2.6/user=neilb/gnupatch@41997cc5nwxi8SY_jN4yhIPUSu_yVA

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
