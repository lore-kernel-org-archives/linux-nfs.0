From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv3/TCP client hangs under load (2.4.17+NFS_ALL)
Date: 13 Apr 2002 20:44:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsads7fnfa.fsf@charged.uio.no>
References: <0204122022230I.01167@stinkpad060501>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16wSWK-0008Re-00
	for <nfs@lists.sourceforge.net>; Sat, 13 Apr 2002 11:45:09 -0700
To: Andrew Ryan <andrewr@nam-shub.com>
In-Reply-To: <0204122022230I.01167@stinkpad060501>
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

>>>>> " " == Andrew Ryan <andrewr@nam-shub.com> writes:

     > The client host is running 2.4.17+NFS_ALL, smp ; otherwise more
     > or less a stock RH7.2 system. The mount uses the following
     > options: v3,tcp,intr,hard,rsize=32768,wsize=32768 The server is
     > a Netapp, fwiw.

     > While the system is hung, turning on /proc/sys/sunrpc/rpc_debug
     > reveals the following to the kernel log. It looks like
     > something is waking up every 5 seconds and trying to process
     > the same request, and failing, and going into some sort of
     > infinite loop.

The rpciod dispatcher is what is supposed to copy data from the TCP
socket back to the NFS layer. If new data is arriving at the socket,
then it is perfectly normal that it should be running. If it never
wakes up any RPC requests, though, then that might indicate that the
client and server out of sync w.r.t. where they think they are in the
data stream.

I'm actually in the process of rewriting this whole part of the TCP
code. For 2.4.19-pre6, the code in the corresponding NFS_ALL patch
should be more robust against interference (and possibly a bit faster
than the old code). It would be nice if you could give it a go...

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
