From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: rpc.mountd + rpc.nfsd
Date: 06 Sep 2002 08:55:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsvg5jli9c.fsf@charged.uio.no>
References: <3D7363A7.8090906@linkvest.com>
	<15732.7907.19389.156631@notabene.cse.unsw.edu.au>
	<3D745D10.4040409@linkvest.com>
	<15732.35929.482032.954554@notabene.cse.unsw.edu.au>
	<3D7490D4.7050307@linkvest.com>
	<15732.39741.104912.607715@notabene.cse.unsw.edu.au>
	<3D760B6D.2040408@linkvest.com> <3D77056C.6020500@linkvest.com>
	<15735.65001.141116.532986@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean-Eric Cuendet <jean-eric.cuendet@linkvest.com>,  nfs@sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15735.65001.141116.532986@notabene.cse.unsw.edu.au>
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

>>>>> " " == Neil Brown <neilb@cse.unsw.edu.au> writes:

     > This explains everything except for the 'void * data' which is
     > nfs specific.

     >    cat /usr/include/linux/nfs_mount.h

     > If some of the fields aren't obvious, get the source for the
     > mount program and read it, or look at the nfs filesystem code
     > in the kernel to see what it does with those fields.

In particular it is worth looking at the NFSroot code
(fs/nfs/nfsroot.c). The latter contains basic code for filling in a
struct nfs_mount.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
