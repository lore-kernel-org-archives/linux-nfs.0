From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: RE: 2.4.19 NFSALL performance oddity
Date: Wed, 9 Oct 2002 16:13:33 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15780.14733.973216.872268@charged.uio.no>
References: <5CA6F03EF05E0046AC5594562398B91653BDC7@poexmb3.conoco.net>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
    <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zHaw-0005eq-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 07:13:50 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B91653BDC7@poexmb3.conoco.net>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

>>>>> " " == Roger A Heflin <Heflin> writes:

     > We should be using sync on the mount option, correct?

No. That shouldn't be necessary. The nfsd server will sync correctly
when told to do so by the client as long as the 'sync' option is set
in /etc/exports.

     > All of my tests used sync on the mount and sync in the export,
     > previously when using async on 2.2.xx (on the export side), and
     > not using the sync option on the mount appeared to cause issues
     > under heavy loads, ie the out of slots warnings, and sometimes
     > worse.

You are saying that server-side caching makes things worse? Could you
please back that up with some numbers?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
