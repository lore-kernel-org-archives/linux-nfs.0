From: "Steve Wolfe" <nw@codon.com>
Subject: Re: rpc.statd and port usage...
Date: Fri, 22 Mar 2002 16:34:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <000901c1d1fa$1b1b7ce0$d281f6cc@iboats.com>
References: <OF6888EE9D.44F71D26-ON88256B84.006AFBD1@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Received: from local.iboats.com ([204.246.129.200])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16oYYK-0003BJ-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Mar 2002 15:34:32 -0800
To: <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

> Use the -o and -p options to rpc.statd for outgoing requests and
listening,
> respectively.  See the manpage for statd.

   Well, it turned out that the original RedHat files were still in /sbin,
which came before /usr/sbin in the path, so I had to move those out of the
way to get the new nfs-utils to load, now the -p works like a charm.

   I can't find any way to get the lock manager to bind to a low port,
however.... are there no options for that one?  Despite the "all:all" in
/etc/hosts.deny, I always feel safer if outside traffic can't get to the
program in the first place....

steve



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
