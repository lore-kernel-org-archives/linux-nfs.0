From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS mount problem on Linux 2.4.20
Date: Mon, 17 May 2004 12:17:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084810646.3669.41.camel@lade.trondhjem.org>
References: <20040517230055.GB19701@arsene.arsene.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPko1-0001Lk-SF
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 09:17:33 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BPko1-0008Rj-Br
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 09:17:33 -0700
To: Doug Lee <douglee@arsene.com.tw>
In-Reply-To: <20040517230055.GB19701@arsene.arsene.com.tw>
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

P=E5 m=E5 , 17/05/2004 klokka 19:00, skreiv Doug Lee:
> Hi,
>=20
> I'm using Linux 2.4.20 without any patches for both nfs server and=20
> client machine. On server side, I have one big file, which size is 9GB.
> On client, when I mount, that file only is about 500MB.
> I try to use Fedora Core 1 and Debian as nfs clients, the result is the s=
ame.
> Would anyone tell me how to solve this issue? Or should I patch which
> diff? Thanks.

Are you perhaps using NFSv2 instead of NFSv3? The former only supports
32-bit filesizes...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
