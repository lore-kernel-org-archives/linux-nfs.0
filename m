From: Gilles Quillard <Gilles.Quillard@Bull.Net>
Subject: support of IPv6 by NFSv4
Date: Tue, 23 Mar 2004 17:23:34 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40606486.473E480D@Bull.Net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5ofy-0007rZ-U1
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 08:22:50 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B5ofx-0005NG-On
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 08:22:50 -0800
Received: from alpha12.frec.bull.fr (alpha12.frec.bull.fr [129.183.146.1])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id RAA20580
	for <nfs@lists.sourceforge.net>; Tue, 23 Mar 2004 17:23:37 +0100
Received: from Bull.Net (localhost [127.0.0.1])
	by alpha12.frec.bull.fr (AIX4.3/8.9.3/8.9.3) with ESMTP id RAA193736
	for <nfs@lists.sourceforge.net>; Tue, 23 Mar 2004 17:23:34 +0100
To: nfs@lists.sourceforge.net
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

Hi,

I'm new in this mailing list. We are interesting by having NFSv4 working over IPv6.
One year ago, Bruce Allan from IBM submitted a patch to add the support of IPv6 in the SUNRPC and in the NFS client/server
kernel part. This patch has not been adopted. Trond, did you remember why this patch has not been taken into account ?

Since this date, there has been no new message on the mailing list about the support of IPv6. Is there some people working on
this subject or interested by it ?

I have begun to look how the support of IPv6 could be integrated in NFS and SUNRPC. The most efficient way seems to be using the
IPv4-mapped IPv6 address format (as described in the sections 3.7 and 6 of RFC2133). With this method, IPv4 addresses are
converted into IPv6 addresses the first time they are used by the user part applications, and then all the address processing is
done using INET6 addresses (simple change of in_addr/sockaddr_in by in6_addr/sockaddr_in6). This method avoids the multiple
tests of the INET family and the corresponding castings. A set of macros/functions (IN6_IS_ADDR_V4MAPPED(), inet_pton(),
inet_ntop(), gethostbyname2(), ...) is available to identify the format of the addresses, to convert and display the addresses
according to their format and to use the name server.

Any comments are welcome.

Gilles.
-- 
Gilles Quillard
Bull Open Software R&D


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
