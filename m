From: ramana <ramana@intraperson.com>
Subject: Re: Autodir and nfs
Date: Mon, 15 Nov 2004 13:13:38 +0530
Message-ID: <41985E2A.2060000@intraperson.com>
References: <4196DB26.9040207@intraperson.com>	 <1100451447.11340.2.camel@lade.trondhjem.org> <1100451550.11340.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTbSy-0003cl-2Y
	for nfs@lists.sourceforge.net; Sun, 14 Nov 2004 23:40:00 -0800
Received: from smtp1.net4india.com ([202.71.129.73] helo=smtp.net4india.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTbSv-0004aX-Sx
	for nfs@lists.sourceforge.net; Sun, 14 Nov 2004 23:39:59 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
In-Reply-To: <1100451550.11340.4.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>Sorry. Should be "man 5 exports"...
>
>Cheers,
>  Trond
>
>  
>
No.

It does not work when whole /home exported like this.
/home          127.0.0.1(rw)

Becuase NFS does not see any dirs within /home dir because of the way 
Autodir works.

It works when individual home dirs exported like this.
/home/t1000     127.0.0.1(rw)

Regards
ramana

-- 
http://www.intraperson.com




-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
