From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: ngroups limitation in NFS/RPC Protocol
Date: 08 Oct 2003 10:18:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy8vv3j92.fsf@charged.uio.no>
References: <HMFXM6$0C0E98D32C99B24C45991D3CFD491746@tiscali.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nfs" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A7FA0-0000Av-00
	for <nfs@lists.sourceforge.net>; Wed, 08 Oct 2003 07:19:28 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A7F9z-0006O3-My
	for nfs@lists.sourceforge.net; Wed, 08 Oct 2003 07:19:27 -0700
To: "ludovic.bourdeau@libertysurf.fr" <ludovic.bourdeau@libertysurf.fr>
In-Reply-To: <HMFXM6$0C0E98D32C99B24C45991D3CFD491746@tiscali.fr>
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

>>>>> " " == ludovic bourdeau <ludovic.bourdeau@libertysurf.fr> writes:

     > Hi !!  I try to bypass ngroups limitation (16) in NFS/RPC
     > protocol on a sun 2.6 and 2.8 but i don't find any patch for it
     > !!


     > Anyone can help me please ???


No.... because what you are asking for lies outside the protocol. See
RFC1831: AUTH_SYS is limited to 16 groups.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
