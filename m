From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: cannot mount via nfs
Date: 30 Apr 2003 15:27:44 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswuhcqfn3.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ard7-0008Tf-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 06:28:13 -0700
To: debian-user@zerocrossings.com
References: 
In-Reply-To: <jUsT.aNoTheR.mEsSaGe.iD.1051708716411non specified
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

>>>>> " " == Debian User <debian-user@zerocrossings.com> writes:

     > I have had nfs mounting working in the past ... do not
     > understand why this is not working now. Can anyone help?

     > NFS server:

     > # rpcinfo -p
     >    program vers proto port
     >     100000 2 tcp 111 portmapper 100000 2 udp 111 portmapper
     >     100024 1 udp 2098 status 100024 1 tcp 2079 status 100005 1
     >     udp 2099 mountd 100005 1 tcp 2080 mountd 100005 2 udp 2099
     >     mountd 100005 2 tcp 2080 mountd

You are not starting any NFS daemons. Only mountd is shown to be
running in the above listing.

man rpc.nfsd

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
