From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Insane permissions problem :)
Date: Thu, 18 Jul 2002 20:34:03 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15670.39323.156232.887895@notabene.cse.unsw.edu.au>
References: <20020717225841.GC4853@netlocal.com.br>
	<shsy9c9bcp6.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Joel Franco =?iso-8859-1?q?Guzm=E1n?= <joel.franco@3WT.com.br>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17V8fu-0006Yv-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Jul 2002 03:38:22 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <trond.myklebust@fys.uio.no>) (for <joel.franco@3wt.com.br>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Thu, 18 Jul 2002 20:38:01 +1000
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on  July 18
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

On  July 18, trond.myklebust@fys.uio.no wrote:
> >>>>> " " =3D=3D Joel Franco Guzm=E1n <joel.franco@3WT.com.br> writes=
:
>=20
>      > it, like a ordinary user. In my local /etc/groups file, i am i=
n
>      > the "intranet" group and i should can to write it. Both are
>      > 1007 group id (in my local machine and in the server)
>=20
> ...but are you in the 'intranet' group on your server? If the server
> believes you are not allowed to write to the file, then it will block=

> any attempts to do so.

Nah.. the server just believes the groups in the RPC credential.
The problem is that Joel is in more than 16 groups, and RPC only knows
about the first 16.

Trond: is there a good reason why the client cannot make sure the
groupid of a file is sorted first when accessing that file?  It would
solve 99% of these problems in a very simple way and should (says he
who hasn't looked at the code) not be too hard to achieve.

NeilBrown

>=20
> Cheers,
>   Trond
>=20
>=20
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf

I think it's time to get a new NFS mailing list.  Should we petition
for a=20
   linux-nfs@vger.kernel.org
so as to avoid these obnoxious ads?

NeilBrown

> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
