From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: Help for setting NFS
Date: Mon, 9 Dec 2002 03:32:21 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021209033221.C26400@vestdata.no>
References: <1039388658.925.29.camel@sfondrin-home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10] ident=0)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18LDih-00048M-00
	for <nfs@lists.sourceforge.net>; Sun, 08 Dec 2002 18:32:31 -0800
To: Sfondrini Cesare <cesare.sfondrini@tin.it>
In-Reply-To: <1039388658.925.29.camel@sfondrin-home>; from cesare.sfondrini@tin.it on Mon, Dec 09, 2002 at 12:04:13AM +0100
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

On Mon, Dec 09, 2002 at 12:04:13AM +0100, Sfondrini Cesare wrote:
> Hi to everyone,
>=20
> I'm searching for help for setting NFS between two machines (my home
> Linux host and my laptop)
>=20
> I've red the Linux NFS HOW-TO doc (thanks to Tavis, Nicolai, Seth and
> Tom) but the system is not working.

Any firewalls running?
Try "iptables -L" on both server and client to find out.



--=20
Ragnar Kj=F8rstad


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
