From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: async vs. sync
Date: Mon, 22 Nov 2004 14:14:52 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EBD6@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWMSb-0007iC-2V
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:15:01 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWMSZ-0002tX-0y
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:14:59 -0800
To: "jehan procaccia" <jehan.procaccia@int-evry.fr>
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


> >>[root@arvouin tmp]# mount cobra3:/p2v5f1 -o=20
> >>async,wsize=3D32768,rsize=3D32768,soft /mnt/cobra3
> >
> >um.  you're not using NFS version 3?
> >
> I though it was a default !?

in Linux, only on more recent mount command / kernel combinations is
version 3 the default.

> >not to mention "soft" mounts are also truly the spawn of satan.
> > =20
> >
> OK I remove it, and force nfs v3

note:  soft is probably not a performance issue here, but it will
definitely be a source of silent data corruption.

> However what stricks me is that although I asked for r&wsize=20
> of 32 K ,=20
> looking at /proc/mounts show :
> $cat /proc/mounts
> cobra3:/p2v5f1 /mnt/cobra3 nfs=20
> rw,v3,rsize=3D8192,wsize=3D8192,hard,tcp,lock,addr=3Dcobra3 0 0
>=20
> 8 K r&wsize ??? I also tried with 16K it's still shows 8K ?

that means your server supports only 8KB transfer sizes.  the client and
server negotiate the maximum size of reads and writes at mount time.

have you read some of the excellent reference textbooks listed in the
NFS FAQ?  that might help you to become a little more fluent with the
operation of NFS.

> howerver=20
> moving from soft to hard did shows up in /proc/mounts .
> Again, How can we check every options of an NFS mounted filesystem on=20
> the client side ? (other than /proc/mountd) .

some options don't show up when they are at their default settings.
no-one ever specifies "async" as a mount option, as it is the default,
so it is not included in /proc/mounts.  NFS version isn't listed in
/proc/mounts unless it was specified on the original mount command.
otherwise, i quite agree with you that every setting should be spelled
out in /proc/mounts, but unfortunately that's not the way it works
today.

the only way to truly see what's going on is to capture a network trace
and load it up in ethereal.  in fact, i recommend that as your next step
-- capture about 30 seconds of your test workload with tcpdump to see
what's going over the wire.  ethereal also has a nice RPC round trip
average calculator.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
