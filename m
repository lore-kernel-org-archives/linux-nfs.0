From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Insane permissions problem :)
Date: 18 Jul 2002 11:35:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy9c9bcp6.fsf@charged.uio.no>
References: <20020717225841.GC4853@netlocal.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17V7hb-0003YM-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Jul 2002 02:36:04 -0700
To: Joel Franco =?iso-8859-1?q?Guzm=E1n?= <joel.franco@3WT.com.br>
In-Reply-To: <20020717225841.GC4853@netlocal.com.br>
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

>>>>> " " =3D=3D Joel Franco Guzm=E1n <joel.franco@3WT.com.br> writes:

     > it, like a ordinary user. In my local /etc/groups file, i am in
     > the "intranet" group and i should can to write it. Both are
     > 1007 group id (in my local machine and in the server)

...but are you in the 'intranet' group on your server? If the server
believes you are not allowed to write to the file, then it will block
any attempts to do so.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
