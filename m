From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS_All on alpha
Date: 04 Sep 2002 00:59:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs3csqr869.fsf@charged.uio.no>
References: <1031086991.5196.53.camel@twitch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mMeF-0007AK-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Sep 2002 15:59:51 -0700
To: "David B. Ritch" <dritch@hpti.com>
In-Reply-To: <1031086991.5196.53.camel@twitch>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == David B Ritch <dritch@hpti.com> writes:

     > Should xdr_shift_buf take an int or a long?  Are there any

It should indeed take a size_t as is done in 2.5.x, and
2.4.20-pre5. Sorry I forgot to apply that change to my own tree.

     > other known problems for a 64-bit architecture in the nfs_all
     > patches?

Not that I'm aware of.

Cheers,
  Trond

diff -Nru a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
--- a/include/linux/sunrpc/xdr.h	Wed Sep  4 00:58:53 2002
+++ b/include/linux/sunrpc/xdr.h	Wed Sep  4 00:58:53 2002
@@ -138,7 +138,7 @@
  */
 extern int xdr_kmap(struct iovec *, struct xdr_buf *, unsigned int);
 extern void xdr_kunmap(struct xdr_buf *, unsigned int);
-extern void xdr_shift_buf(struct xdr_buf *, unsigned int);
+extern void xdr_shift_buf(struct xdr_buf *, size_t);
 extern void xdr_zero_buf(struct xdr_buf *, unsigned int);
 
 /*


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
