From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.18: NFS_ALL patch greatly hurting UDP speed
Date: Wed, 20 Mar 2002 16:50:01 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15512.44969.304675.703836@charged.uio.no>
References: <3C88F8EE.86058BD5@sls.lcs.mit.edu>
	<shs7kollatu.fsf@charged.uio.no>
	<3C98AD4B.8244EDC0@sls.lcs.mit.edu>
	<15512.44669.95177.801025@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16niLt-0000qO-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 07:50:13 -0800
To: I Lee Hetherington <ilh@sls.lcs.mit.edu>,
In-Reply-To: <15512.44669.95177.801025@charged.uio.no>
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

>>>>> " " == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

     > exceeded' ICMP messages littered around the place. The first
     > one comes just after the loss of fragments, and is accompanied
     > by a 2 second delay, during which all the reads that are sent
     > time out without receiving a single reply...

Note: this 2 second period of silence appears to be what is really
causing the *100 slowdown. I've no idea what the switch is engaging in
during that time, but you might want to take a look to see if those
messages being sent during that period are indeed being received on
the server.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
