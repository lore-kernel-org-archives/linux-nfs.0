From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: limit on filesystem size?
Date: Fri, 2 Aug 2002 23:43:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020802234342.N20768@vestdata.no>
References: <20020801195309.GA26793@stikine.ucs.sfu.ca> <shs7kja48km.fsf@charged.uio.no> <008401c23a6b$489bd8c0$fd0912ac@analytical>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Martin Siegert <siegert@sfu.ca>,
   Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17akDP-00032W-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 14:44:07 -0700
To: Steve Costaras <stevecs@oceanbay.com>
In-Reply-To: <008401c23a6b$489bd8c0$fd0912ac@analytical>; from stevecs@oceanbay.com on Fri, Aug 02, 2002 at 04:26:35PM -0500
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

On Fri, Aug 02, 2002 at 04:26:35PM -0500, Steve Costaras wrote:
> How are you planning on creating this filesystem?    I have tried
> creating 2TB filessystems here for a while and have had little or no
> luck w/ Solaris or linux.  Using Disksuite for solaris and LVM and MD f=
or
> linux no luck.  I have not tried veritas VM yet but even calling up SUN
> the answer is that 1TB is the limit per filesystem currently under sola=
ris 8
> & 9
>=20
> Linux is really around 980GB or so where it starts to flake out.

Linux goes up to 2 TB if you use a scsi-driver that use unsigned
sector-numbers and a recent version of LVM (or no LVM).



--=20
Ragnar Kj=F8rstad
Big Storage


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
