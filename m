From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: knfsd & unfsd on the same server
Date: 27 Feb 2003 18:54:10 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsheapip8d.fsf@charged.uio.no>
References: <200302271745.20691.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: clusternfs-users@lists.sourceforge.net,  <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200302271745.20691.bernd-schubert@web.de>
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

>>>>> " " == Bernd Schubert <bernd-schubert@web.de> writes:

     > mount -t nfs -o mountprog=110005,nfsprog=110003,port=2050
     > localhost:/test1 /mnt/test2

The 'nfsprog' option is unsupported by the Linux NFS client as the
mount program has no way of passing the number down to the kernel.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
