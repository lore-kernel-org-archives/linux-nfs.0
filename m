From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: NFS mount option - noac forces sync even if async is specified, and no warning is given
Date: Mon, 3 Feb 2003 12:28:56 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B916A7F982@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18flL8-0005O5-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 10:29:06 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


I run the following command:

mount -t nfs -o rw,hard,lock,intr,noac,async=20
     hoepld31:/ptmp/hoepld31 /tmpmnt/ptmp/hoepld31

And then cat /proc/mounts:

hoepld31:/ptmp/hoepld31 /tmpmnt/ptmp/hoepld31 nfs =
rw,sync,v3,rsize=3D8192,
     =
wsize=3D8192,acregmin=3D0,acregmax=3D0,acdirmin=3D0,acdirmax=3D0,hard,int=
r,
     udp,noac,lock,addr=3Dhoepld31 0 0

Note that async is specified on the mount line and /proc/mounts
specifies that sync was used.  If I don't use the async option the same
thing happens.  This is with 2.4.21pre3 NFSALL and utils-1.0.1-1 (as
included by RH7.3)  for the client.  The server is 2.4.19 NFSALL=20
(an earlier NFSALL), I don't believe the server makes a difference
on the issue of the client not seeming to recogonize the sync=20
option.   The client and server are both originally based on RH7.3.

If I remove the noac option, then the async option seems to be
honered, but not with the noac option on the line, is this the =
documented=20
behavior?  And should something give a warning since one user
specified options overrides another user specified option in a=20
very nonobvious way?

The write performance stinks rather badly with the sync option=20
enabled, and I could see why you *might* want to force it with
noac, but not if the user is attempting to override the sync option
with async.

SYNC is specified on the exports line on the remote server, and my
understanding was that you want sync on the exports line, and=20
async on the mount line on the client, but I cannot seem to get it
to take async on the mount line (no error is given, but it appears
to have been ignored, trying a known bad option -say nosync does
give a error saying bad option).

				Roger




-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
