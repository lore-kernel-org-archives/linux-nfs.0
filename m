From: Olaf Kirch <okir@suse.de>
Subject: Re: nfsd: terminating on error 104 problem
Date: Thu, 4 Mar 2004 12:11:38 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040304111138.GO22726@suse.de>
References: <404707BE.9070401@framestore-cfc.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="R3G7APHDIzY6R/pk"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyqrI-0000Qj-7K
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 03:17:44 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AyqRq-0004FA-9N
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 02:51:26 -0800
To: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
In-Reply-To: <404707BE.9070401@framestore-cfc.com>
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


--R3G7APHDIzY6R/pk
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On Thu, Mar 04, 2004 at 10:41:02AM +0000, Johan van den Dorpe wrote:
> So from my limited knowledge of the kernel source I can see that 
> "terminating on error 104" corresponds to line 221 of
> /usr/src/linux-2.4.25/fs/nfsd/nfssvc.c. So svc_recv on line 191 is 
> obviously returning -104.

104 is ECONNRESET, this means the client reset the connection.
The server should really clean up the socket in this case.

Does the attached patch help? 

Beware - totally untested, better not try this on a production
machine :)

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--R3G7APHDIzY6R/pk
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=nfsd-handle-econnreset

--- svcsock.c.orig	2004-03-04 12:08:51.000000000 +0100
+++ svcsock.c	2004-03-04 12:10:08.000000000 +0100
@@ -904,6 +904,10 @@
 	if (len == -EAGAIN) {
 		dprintk("RPC: TCP recvfrom got EAGAIN\n");
 		svc_sock_received(svsk);
+	} else if (len == -ECONNRESET) {
+		dprintk("RPC: TCP recvfrom got ECONNRESET\n");
+		svc_sock_received(svsk);
+		set_bit(SK_DEAD, &svsk->sk_flags);
 	} else {
 		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
 					svsk->sk_server->sv_name, -len);

--R3G7APHDIzY6R/pk--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
