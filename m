From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux NFS client against Auspex server crashes
Date: 21 Jan 2003 17:28:27 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs65si4gd0.fsf@charged.uio.no>
References: <5CA6F03EF05E0046AC5594562398B9160C780A@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18b1GP-0000Lj-00
	for <nfs@lists.sourceforge.net>; Tue, 21 Jan 2003 08:28:38 -0800
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B9160C780A@POEXMB3.conoco.net>
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

     > 	What kernel/nfs should we try to duplicate this one?
     > 	2.4.21pre3+NFSALL?  And I will see if I can get a trace of
     > 	exactly what is happening just before the crash.

AFAIK 2.4.21pre3 + NFS_ALL should be up to date w.r.t all known
problems + fixes (2.4.19, however, is *not*), so testing that out
first would be most useful.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: Scholarships for Techies!
Can't afford IT training? All 2003 ictp students receive scholarships.
Get hands-on training in Microsoft, Cisco, Sun, Linux/UNIX, and more.
www.ictp.com/training/sourceforge.asp
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
