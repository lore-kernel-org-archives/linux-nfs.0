From: "Amir Hermelin" <amir@montilio.com>
Subject: RE: nfsd and kswapd
Date: Mon, 7 Jun 2004 12:15:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <004c01c44c78$5f789120$0200000a@CARTMAN>
References: <1086596506.24334.9.camel@ikarus.inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXGEM-0005sb-H1
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 02:15:46 -0700
Received: from enigma.barak.net.il ([212.150.48.101])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BXGEL-0003RI-Hk
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 02:15:45 -0700
To: "'Marc Schmitt'" <mschmitt@inf.ethz.ch>
In-Reply-To: <1086596506.24334.9.camel@ikarus.inf.ethz.ch>
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

Thanks Marc for the info.  It so happens I'm also using a PowerEdge =
(2600),
so I'll check out that thread.  I'm using a RH 9 system, kernel 2.4.20-8 =
-
should that include the better mem management you've mentioned?



-----Original Message-----
From: Marc Schmitt [mailto:mschmitt@inf.ethz.ch]=20
Sent: Monday, June 07, 2004 10:22 AM
To: Amir Hermelin
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] nfsd and kswapd


Hi Amir,

On Mon, 2004-06-07 at 00:46, Amir Hermelin wrote:
> Hi,
> I'm observing a strange phenomenon running nfsd on 2.4.20 (RH).  I'm=20
> using a dual-Xeon server with 6GB of memory, and 40 nfsd threads=20
> running.  Under very heavy load, after a while kswapd starts=20
> constantly occupying between 60-90% cpu, and every once in a while=20
> keventd also wakes up with some 10- 30% of its own.  This obviously=20
> slows the system and greatly reduces the nfs performance.  The=20
> strangest thing is, that when I reduce the memory to 512MB (with the=20
> mem boot option), kswapd seems to be getting a lot less CPU.
>=20
> Any explanations on the matter would be greatly appreciated.

Is that a RH 7.3 system? If so, make sure you're running kernel =
2.4.20-28 or
later, it has the memory management of RH 9 backported and behaves much
better in a setup like yours.

There were many discussions about this on the Dell Linux PowerEdge list, =
one
thread started here:
http://lists.us.dell.com/pipermail/linux-poweredge/2003-May/024785.html

One workaround is to disable swap, not sure if that's on option for you
though. Depends on what you're running other than file serving.

Greetings,
     Marc



-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
