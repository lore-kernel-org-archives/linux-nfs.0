From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd recovery not working on RH with 2.6 kernel
Date: Fri, 19 Nov 2004 11:34:59 -0500
Message-ID: <1100882099.11209.8.camel@lade.trondhjem.org>
References: <OF573E8465.7E3D5CC0-ON88256F49.0064BB5C-88256F49.00698B56@us.ibm.com>
	 <419CD343.4000600@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-RwQ4/1O9hARgCOtn+uiU"
Cc: NFS@lists.sourceforge.net, Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <419CD343.4000600@RedHat.com>
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


--=-RwQ4/1O9hARgCOtn+uiU
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

to den 18.11.2004 Klokka 11:52 (-0500) skreiv Steve Dickson:
> Well it appears things are a bit broken. Here is a client side patch that
> enables the client to reclaim locks on a rebooted server.
> 
> The two main issues were nlm4svc_decode_reboot() not setting
> the protocol which cause the nlm_host structure not to be found
> and two, making nlmclnt_reclaim() retry when the portmapper was up
> but lockd had not made it yet.... I also fixed a debugging
> statement and well as added a couple... that I found useful....

Yep. Good work!

> Now the reclaim retry code currently retries forever in an
> interruptible loop waiting for lockd to come up. This may or
> may not be a good idea, but the client should not make any
> assumptions about the health of the server, to I'm not sure there
> is anything else that can be done....
> 
> Unfortunately this reclaim code freaks out the linux server, causing it
> to send two back-to-back messages (both using the same xid) that
> fails and then grant the lock.... It seems the dentry_open() call
> (in nfsd_open()) is returning 30000 error value. Its not clear why or
> what a 30000 value means....  I'm still looking in to that, but this code
> was tested with both a Neapps filer and Solaris 10 server which seem
> to work fine..

30000 ???? All kernel errors should be < 1000. Is this the perhaps the
bug with the unintialized variable in the mountd upcall code? I believe
the attached patch has already been committed to the nfs-utils CVS tree.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-RwQ4/1O9hARgCOtn+uiU
Content-Disposition: inline
Content-Description: Vedlagt melding - Fix a problem with an uninitialized
	variable in rpc.mountd...
Content-Type: message/rfc822

Subject: Fix a problem with an uninitialized variable in rpc.mountd...
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Neil Brown <neilb@cse.unsw.edu.au>
Cc: "Dr. Bruce Fields" <bfields@fieldses.org>
Content-Type: text/plain
Message-Id: <1094438066.10492.73.camel@lade.trondhjem.org>
Mime-Version: 1.0
X-Mailer: Ximian Evolution 1.4.6 
Date: Sun, 05 Sep 2004 22:34:26 -0400
X-Evolution-Transport: smtp://trondmy;auth=PLAIN@smtp.uio.no/;use_ssl=always
X-Evolution-Account: trond.myklebust@fys.uio.no (imap)
X-Evolution-Fcc: imap://trondmy@imap.uio.no/INBOX/Sent
X-Evolution-Format: text/plain
Status: RO
Content-Length: 558
X-UID: 274
X-Keywords: 
X-Evolution-Source: imap://trondmy@imap.trondhjem.org/
Content-Transfer-Encoding: 7bit

Currently, mountd return an "error -1073752996" on my laptop when it
cannot lookup the IP address.

Cheers,
  Trond

--- nfs-utils-1.0.6/utils/mountd/auth.c.orig	2003-07-14 18:10:12.000000000 -0400
+++ nfs-utils-1.0.6/utils/mountd/auth.c	2004-09-05 21:25:09.000000000 -0400
@@ -80,6 +80,7 @@ auth_authenticate_internal(char *what, s
 			my_client.m_naddr = 0;
 			my_client.m_addrlist[0] = caller->sin_addr;
 			n = client_compose(caller->sin_addr);
+			*error = unknown_host;
 			if (!n)
 				return NULL;
 			strcpy(my_client.m_hostname, *n?n:"DEFAULT");


--=-RwQ4/1O9hARgCOtn+uiU--



-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
