From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS and UDP port 1434
Date: 01 Feb 2003 10:04:02 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr8aspe2l.fsf@charged.uio.no>
References: <E67F8F12671DF54FB828481785943030037EB836@cceexc22.americas.cpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18etZK-0006bi-00
	for <nfs@lists.sourceforge.net>; Sat, 01 Feb 2003 01:04:10 -0800
To: "Morong, Gerry" <Gerry.Morong@hp.com>
In-Reply-To: <E67F8F12671DF54FB828481785943030037EB836@cceexc22.americas.cpqcorp.net>
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

>>>>> " " =3D=3D Gerry Morong <Morong> writes:

     > Have a hundred plus Red Hat 7.3 NFS clients connecting to
     > several NetApps and Red Hat 7.3 fileservers.=A0 They are
     > configured to run NFS V3 over UDP.=A0 When the SQL slammer bug
     > hit our routers were reconfigured to block UPD port 1434.=A0 This
     > caused sporadic NFS lockups for mounts outside the local subnet
     > subject to the port blocking.=A0 Once the port blocking was
     > cleared from the routers, NFS connections freed up and started
     > working again. What part of NFS should be using UDP port 1434?=A0

'/usr/sbin/rpcinfo -p' will tell you.

It is probably either rpc.statd or rpc.lockd

Cheers,
  Trond





-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
