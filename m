From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Autodir and nfs
Date: Mon, 15 Nov 2004 10:44:23 -0500
Message-ID: <1100533463.11246.3.camel@lade.trondhjem.org>
References: <4196DB26.9040207@intraperson.com>
	 <1100451447.11340.2.camel@lade.trondhjem.org>
	 <1100451550.11340.4.camel@lade.trondhjem.org>
	 <41985E2A.2060000@intraperson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTj25-0004Ob-VI
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 07:44:45 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTj24-0005RX-ER
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 07:44:45 -0800
To: ramana <ramana@intraperson.com>
In-Reply-To: <41985E2A.2060000@intraperson.com>
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

m=E5 den 15.11.2004 Klokka 13:13 (+0530) skreiv ramana:

> It does not work when whole /home exported like this.
> /home          127.0.0.1(rw)
>=20
> Becuase NFS does not see any dirs within /home dir because of the way=20
> Autodir works.
>=20
> It works when individual home dirs exported like this.
> /home/t1000     127.0.0.1(rw)

Probably because user "nobody" does not have access to /home on the
server. RTFM about root squashing...

Cheers,
  Trond

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
