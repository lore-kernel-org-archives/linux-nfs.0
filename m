From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Secure user authentication using RPCSEC_GSS [0/7]
Date: Thu, 31 Oct 2002 21:19:09 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15809.36925.535370.248020@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>, nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187Lml-0002xg-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 12:19:23 -0800
To: Linus Torvalds <torvalds@transmeta.com>
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


RPCSEG_GSS is the security mechanism of choice for NFSv4. It provides
a protocol for negotiating secure authentication and data transfers on
a per-user basis in a manner that is independent of the underlying
security mechanisms.

The actual security negotiation can be done out of band, so it makes
sense to delegate as much of this as possible to a userland
daemon. The result of negotiation is a security 'context' which is
cached in the kernel, and is subsequently used for authentication (as
part of the credential in the RPC header) and/or for data
integrity/privacy protection (using whatever crypto mechanism your
chosen security mechanisms support).

The following set of patches provide basic kernel RPC client support
for the generic RPCSEC_GSS protocol, and for communicating with a
userland daemon that does the actual the security context negotiation
with the RPC server.
Communication between kernel and userland is done over a set of named
pipes (in much the same way as the CODA upcall/downcall is done) in a
private ramfs-like filesystem.

This set of 7 patches does not include any actual security
mechanisms, and only provides the functionality necessary to do
client-side user authentication. A subsequent patch will add the
Kerberos 5 security functionality.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
