From: Chris Croswhite <csc@cadence.com>
Subject: Re: Re: Linux 2.4.25, nfs client hangs when talking to a
	MacOS nfs server.
Date: Wed, 17 Mar 2004 10:01:02 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1079546462.3769.249.camel@d158140025182.Cadence.COM>
References: <117F2C39-7800-11D8-93C6-000A95CFFC9C@idtect.com>
	 <1079542707.3047.12.camel@lade.trondhjem.org>
	 <4825B7F5-783A-11D8-97E9-000A95CFFC9C@idtect.com>
Reply-To: csc@cadence.com
Mime-Version: 1.0
Content-Type: text/plain; charset=
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3fJn-0006XP-RC
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 09:59:03 -0800
Received: from mailgate2.cadence.com ([158.140.2.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B3fJm-0003cN-35
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 09:59:02 -0800
To: Charles-Edouard Ruault <ce@idtect.com>
In-Reply-To: <4825B7F5-783A-11D8-97E9-000A95CFFC9C@idtect.com>
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

I have seen similar issues, but with slowlaris NFS server to linux.=20
Never was able to resolve the issue and so moved to linux NFS server. =20

I am willing to spend sometime on this issue if Trond can give me some
assistance?  I can detail the issue if you have you are available.

TIA,
Chris

On Wed, 2004-03-17 at 09:41, Charles-Edouard Ruault wrote:
> On Mar 17, 2004, at 5:58 PM, Trond Myklebust wrote:
>=20
> > P=C3=A5 on , 17/03/2004 klokka 05:44, skreiv Charles-Edouard Ruault:
> >
> > [snip]
>=20
> > Your Mac server is replying slooooooooowwwwwwwwllllllllllyyyyyyyyyyy.
> > That either indicates that you have a dirty network which is losing
> > packets (can happen if you are mixing 10Mbps and 100Mbps segments) or
> > the Mac server is hanging.
> >
> > Cheers,
> >   Trond
> >
> Hi Trond,
> thanks for the quick reply.
> As you pointed out i've got a network which mixes 100Mbps and 1Gbps (=20
> the mac is on 1Gps and the linux on 100Mbps ).
> However i've done a little troubleshooting on the network and i achieve=
=20
> full 100Mbps speed scp'ing files from/to both machines.
> I've also tried to use nfs over tcp instead of udp and it does not=20
> change anything.
> I've got a Gigabit card for the Linux box and i've scheduled to install=
=20
> it within the next few days. I'll see if this helps or not.
> In the meantime, any other hint is welcome.
> Thanks.
>=20
>=20
> Charles-Edouard Ruault
> Idtect SA
> tel: +33-1-42-81-81-84
> fax: +33-1-42-81-82-21
> http://www.idtect.com
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id=1470&alloc_id638&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
