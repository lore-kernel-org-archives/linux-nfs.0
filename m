From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Root-NFS problem
Date: 13 May 2003 22:00:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1xz21ut0.fsf@charged.uio.no>
References: <005001c31986$ec556f80$6464a8c0@foxie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ffwn-0007t3-00
	for <nfs@lists.sourceforge.net>; Tue, 13 May 2003 13:00:25 -0700
To: "Martynas Buozis" <martynas@ti.com>
In-Reply-To: <005001c31986$ec556f80$6464a8c0@foxie>
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

>>>>> " " == Martynas Buozis <martynas@ti.com> writes:


     > This is how boot process ends when I use Celerra as NFS server

     > Looking up port of RPC 100003/2 on aaa.bbb.ccc.xxx Looking up
     > port of RPC 100005/1 on aaa.bbb.ccc.xxx call_verify: server
     > accept status: 5 call_verify: server accept status: 5
     > call_verify: server accept status: 5 RPC: garbage, exit EIO
     > Root-NFS: Server returned error -5 while mounting
     > /BOOTP/redhat/8.0/ VFS: Unable to mount root fs via NFS, trying
     > floppy.

rfc1831 lists accept status error number 5 as being

  SYSTEM_ERR    = 5  /* errors like memory allocation failure */
 
Looks like your server is in some sort of trouble...

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
