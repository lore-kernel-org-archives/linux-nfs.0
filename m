From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS mount option - noac forces sync even if async is specified, and no warning is given
Date: 03 Feb 2003 21:49:56 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr8ap5bt7.fsf@charged.uio.no>
References: <5CA6F03EF05E0046AC5594562398B916A7F982@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fnXY-0004eV-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 12:50:04 -0800
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B916A7F982@POEXMB3.conoco.net>
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

>>>>> " " == Roger A Heflin <Heflin> writes:

     > I run the following command:

     > mount -t nfs -o rw,hard,lock,intr,noac,async
     >      hoepld31:/ptmp/hoepld31 /tmpmnt/ptmp/hoepld31

     > And then cat /proc/mounts:

     > hoepld31:/ptmp/hoepld31 /tmpmnt/ptmp/hoepld31 nfs
     > rw,sync,v3,rsize=8192,
     >      wsize=8192,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,intr,
     >      udp,noac,lock,addr=hoepld31 0 0

     > Note that async is specified on the mount line and /proc/mounts
     > specifies that sync was used.  If I don't use the async option

That's right. 'noac' enforces 'sync' in order to remain compatible
with the expected behaviour of noac on other NFS client
implementations.

If you don't need 'sync', you can specify

   acregmin=0,acregmax=0,acdirmin=0,acdirmax=0

instead.

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
