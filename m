From: "Amir Hermelin" <amir@montilio.com>
Subject: RE: nfsd and kswapd
Date: Mon, 7 Jun 2004 12:17:07 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <004d01c44c78$96475420$0200000a@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXGFn-0006Po-L5
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 02:17:15 -0700
Received: from enigma.barak.net.il ([212.150.48.101])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXGFn-00056s-5H
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 02:17:15 -0700
To: "'Amir Hermelin'" <amir@montilio.com>,
	"'Marc Schmitt'" <mschmitt@inf.ethz.ch>
In-Reply-To: 
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

BTW also I'm not running anything else significant other than knfsd, and =
it
appears that there isn't actual swapping going on.

Thanks,
Amir.


-----Original Message-----
From: Amir Hermelin [mailto:amir@montilio.com]=20
Sent: Monday, June 07, 2004 12:16 PM
To: 'Marc Schmitt'
Cc: 'nfs@lists.sourceforge.net'
Subject: RE: [NFS] nfsd and kswapd


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
> I'm observing a strange phenomenon running nfsd on 2.4.20 (RH).  I'm
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
