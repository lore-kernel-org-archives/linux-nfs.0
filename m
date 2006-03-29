From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: timeo & retrans, smaller max timeout than 60 seconds?
Date: Wed, 29 Mar 2006 09:07:52 -0500
Message-ID: <1143641272.7928.13.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0603290921500.2597@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FObLU-0003v6-Ua
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 06:08:24 -0800
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FObLT-0000SQ-Eg
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 06:08:24 -0800
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0603290921500.2597@maggie.lkpg.cendio.se>
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

On Wed, 2006-03-29 at 09:44 +0200, Peter =C3=85strand wrote:
> Hi. We are using unfsd to provide "personal" mounts in a thin client=20
> environment, based on NFSv3 over TCP over SSH. This works fairly good, bu=
t=20
> we would like a little shorter timeout when the server doesn't respond=20
> (such as when the user has disabled file sharing and thus stopped unfsd).=
=20
> Currently, we are mounting with:
>=20
> rw,noexec,nosuid,nodev,port=3DXXXX,mountport=3DXXXX,mountvers=3D3,nfsvers=
=3D3,nolock,fg,soft,intr,tcp,actimeo=3D2,addr=3D127.0.0.1
>=20
> The important options wrt timeout here is:
>=20
> fg,soft,intr,tcp
>=20
> So, we are not using timeo or retrans at all. The result is timeouts=20
> varying between 3 and 180 seconds. The worst case seems to be when doing =
a=20
> "kill -STOP" on unfsd (thus, simply not respond, in contrast to respond=20
> with EOF or similiar).
>=20
> My questions are:
>=20
> * How can we lower the timeouts? To me, it seems like the hardcoded
>    maximum timeout of 60 seconds is a bit of a problem. How about
>    introducing an option for changing this?

The maximum timeout for TCP is 600 seconds, i.e. 10 minutes.

>    If we start using, say, retrans=3D1, does this mean that applications =
can
>    recieve EIO after as little as 1 second?

No. "timeo" controls the timeout value. "retrans" controls the number of
retransmissions before a major timeout is declared.

> * Is it true that all the "-f" option to umount does is skip trying
>    MOUNTPROC_UMNT?

No. '-f' causes all pending RPC calls to be cancelled (and return -EIO).

> * About "intr": The man page says "If an NFS file operation has a major
>    timeout and it is hard mounted". Does "intr" affect soft mounts in any
>    way, or is it better to remove it?

Intr changes the set of signals that are able to interrupt an RPC call.
It has nothing to do with "soft".

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
