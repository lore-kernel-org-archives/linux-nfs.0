From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RedHat 8.0 nfs
Date: 26 Mar 2003 00:19:18 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr88v3uh5.fsf@charged.uio.no>
References: <D38AFB3080F3D311807300B0D0203E53033A94D5@MERCURY>
	<Pine.LNX.4.51.0303251547190.3799@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "pwitting@Cyveillance.com" <pwitting@cyveillance.com>,
	  "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18xxhc-0005nt-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Mar 2003 15:19:33 -0800
To: David Dougall <davidd@et.byu.edu>
In-Reply-To: <Pine.LNX.4.51.0303251547190.3799@lewis.et.byu.edu>
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

>>>>> " " == David Dougall <davidd@et.byu.edu> writes:

     > This doesn't agree with what I have heard before.  I was always
     > told that this memory amount( 256k default) was shared by all
     > threads.  Therefore the more threads you had, the more

You were misinformed. In Linux 2.4.x, each RPC server thread allocates
a private buffer.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
