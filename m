From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs performance: read only/gigE/nolock/1Tb per day
Date: 22 Apr 2002 17:32:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shssn5noik3.fsf@charged.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E50CEB5@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'jason andrade'" <jason@dstc.edu.au>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zfoS-0004me-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 08:33:08 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E50CEB5@black.eng.netapp.com>
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

>>>>> " " == Charles Lever <Lever> writes:

     > i'm looking at a similar problem (1K rsize works, but 8K rsize
     > doesn't behave under load; only a server reboot will fix the
     > problem).  the environment is also a web server running an NFS
     > client, but the back-end is a NetApp filer.  the NFS traffic
     > goes over a private switched 100MB network.

     > try with NFSv3 and TCP.  my guess is you have a network problem
     > of some kind that causes packet loss.  this triggers the UDP
     > timeout/recovery mechanism which will slow you down and maybe
     > even get the server and client out of sync with each other.
     > you might also check your GbE settings -- flow control should
     > be enabled, and make sure both ends of all your links have
     > identically configured autonegotiation parameters.

     > (trond- losing sync may be a client problem since it appears to
     > happen with different server implementations.  what can we do
     > to get better information about this?)

I'm not sure what you mean by this. There is no 'sync' with UDP: each
packet going down the wire is either a UDP header or a fragment.

What might perhaps be happening is that the cards are somehow getting
messed up due to data flooding. Have you tried playing around with
driver parameters such as 'max_interrupt_work', 'max_rx_desc' and/or
other interrupt-related variables? (see 'modinfo -p <module>' for the
list of supported paramenters)

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
