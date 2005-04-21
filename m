From: Nix <nix@esperi.org.uk>
Subject: NFSv3 GETATTR/ACCESS requests flooding the network since upgrading
 to 2.6
Date: Thu, 21 Apr 2005 18:31:55 +0100
Message-ID: <87r7h4gho4.fsf@amaterasu.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOfX4-0002ER-2i
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 10:32:06 -0700
Received: from 41-052.adsl.zetnet.co.uk
	([194.247.41.52] helo=mail.esperi.org.uk ident=user62540)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DOfX2-0004re-6j
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 10:32:05 -0700
Received: from esperi.org.uk (nix@amaterasu.srvr.nix [192.168.14.14])
	by mail.esperi.org.uk (8.12.11/8.12.11) with ESMTP id j3LHVupJ029594
	for <nfs@lists.sourceforge.net>; Thu, 21 Apr 2005 18:31:56 +0100
To: nfs@lists.sourceforge.net
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

I upgraded from 2.4.28 to 2.6.10 (and then .11) a month ago. In 2.6.11
at least, and probably in 2.6.10 (alas, I didn't notice this behaviour
early enough to be sure: I can reboot into 2.6.10 and see if it
disappears if anyone wants), the Linux NFS client / kernel server
combination has been absolutely *flooding* the network with ACCESS
requests (and to a somewhat lesser extent GETATTR).


This is far worse than anything I've seen in 2.4: even on a 100Mb/s net,
it slows (e.g.) configure runs down to a tenth or less of their normal
speed. A packet dump of ten seconds worth of a run of bfd configure
shows more than 40,000 UDP packets, 95% of them GETATTR and ACCESS
requests for the same inodes repeated over and over again microseconds
apart. There appears to be no caching of ACCESS results being done
whatsoever.

(Packet dumps from this ten-second slice of configure run are available,
but they're >8Mb, so I'm not attaching them here.)


The filesystem I tested this on (and where I see most of the problems,
but it's the most heavily used of my NFS filesystems, so this is
unsurprising) is exported from a 2.6.11.6 SPARC64 box as
`rw,no_root_squash,async,wdelay,no_subtree_check' (from
/proc/fs/nfs/exports), and imported onto a number of 2.6.11.6 i386-class
boxes (Pentium, Athlon IV...) all of which show the same symptoms.

I'm running nfs-utils 1.0.7 across the board, but this doesn't seem to
be the class of problems I've seen before where mount fails to
communicate the NFS options properly to the kernel and leaves out the
async or something like that. (I think this has to be a client bug
or obscure feature or something.)


I speculate that this line from the NFS FAQ is relevant:

> The Linux NFS client should cache the results of these ACCESS
> operations. In fact, in the new 2.6.x kernels, it does this and it
> extends ACCESS checking to all users to allow for generic uid/gid
> mapping on the server.

If this means `massive numbers of ACCESS requests will happen when using
2.6', then, well, I'm not using UID/GID mapping[1] and I don't need ACLs
if they do *this* to performance: how do I turn this behaviour off?


[1] in fact, until I read this FAQ entry I was unaware it existed: I
    mourned its loss when I moved away from unfsd / ugidd, so if
    it's back, excellent!

-- 
This is like system("/usr/funky/bin/perl -e 'exec sleep 1'");
   --- Peter da Silva


-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
