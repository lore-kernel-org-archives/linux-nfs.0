From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs performance: read only/gigE/nolock/1Tb per day
Date: 23 Apr 2002 12:39:35 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsu1q2d7h4.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0204222037530.16783-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,  "Lever, Charles" <Charles.Lever@netapp.com>,
	  "'jason andrade'" <jason@dstc.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zxiL-0004Wu-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 03:40:01 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0204222037530.16783-100000@kenzo.iwr.uni-heidelberg.de>
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

>>>>> " " == Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de> writes:

     > "max_interrupt_work" should not be modified unless a message
     > like "ethx: Too much work in interrupt!" is logged by the
     > kernel. In some cases, increasing "max_interrupt_work" without
     > also increasing the Rx ring size would not help...

So what would an avalanche of ICMP Time Exceeded messages usually
indicate as far as the driver/card is concerned?

At the networking levels, a single Time Exceeded message means that
some fragment(s) got dropped and/or lost, so some datagram never got
reassembled within /proc/sys/net/ipv4/ipfrag_low_thresh seconds
(as per RFC1122).

In the avalanching case that I've sometimes observed, then it looks as
if *no* datagrams are getting rebuilt.
IOW: the client is just sitting there sending off ICMP messages, and
never reading the reply. Changing card/driver did not help in the
cases I observed, but shutting down the network, and then bringing it
up again sometimes did. Any suggestions?

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
