From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: error when insmod nfsd: unresolved symbol nfsd_linkage
Date: 12 Apr 2002 14:34:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsg02185a6.fsf@charged.uio.no>
References: <20020412135551.D26281@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16w0GN-0007fV-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Apr 2002 05:34:47 -0700
To: Dumas Patrice <dumas@centre-cired.fr>
In-Reply-To: <20020412135551.D26281@zeus.centre-cired.fr>
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

>>>>> " " == Dumas Patrice <dumas@centre-cired.fr> writes:

     > Hi, I have just compiled linux-2.4.18 with
     > linux-2.4.18-NFS_ALL.dif applied. All the nfs stuff was
     > compiled as modules (without over TCP support). I made some
     > changes in lockd/svcproc.c, but I touched nothing anywhere
     > else. I am on a redhat 7.2, but the kernel is a normal kernel.

     > Now, when I try to insmod the nfsd module (after sunrpc and
     > lockd), I get

     > ./nfsd.o: unresolved symbol nfsd_linkage

The above usually means that the kernel was compiled without
'CONFIG_NFSD=m' being set.
You probably forgot to run 'make oldconfig' after changing the .config
file by hand or something like that.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
