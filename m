From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Fri, 27 Aug 2004 17:51:30 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093643490.5758.120.camel@lade.trondhjem.org>
References: <20040827212244.GA57703@brandon.dvalentine.com>
	 <1093642565.5758.108.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0odB-000871-43
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 14:51:33 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C0od9-0004wT-Jp
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 14:51:32 -0700
To: "Brandon D. Valentine" <brandon@dvalentine.com>
In-Reply-To: <1093642565.5758.108.camel@lade.trondhjem.org>
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

P=C3=A5 fr , 27/08/2004 klokka 17:36, skreiv Trond Myklebust:
> P=C3=A5 fr , 27/08/2004 klokka 17:22, skreiv Brandon D. Valentine:
>=20
> > Given the fact that the mount fails manually until vers=3D2 is specifie=
d I
> > am inclined to believe this is a kernel NFS bug, not an autofs or mount
> > bug.
>=20
> Sorry. I conclude the exact opposite. The problem here is the "mount"
> program autoprobe failing.

To be more specific, I believe the problem here is that you are using an
NFSv2-only kernel together with a version of mountd that is advertising
NFSv2 *and* NFSv3.

We used to have code in the kernel that retried using NFSv2 if the NFSv3
GETATTR call failed. I ripped that out of 2.6.x since people have had
ample time (I'd say 4-5 years is pretty ample) to correct their setups.
Add the '--no=E2=80=90nfs=E2=80=90version 3' flag to your rpc.mountd startu=
p script,
just as the mountd manpage clearly states you should do, and all will be
well.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
