From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs performance: read only/gigE/nolock/1Tb per day
Date: 23 Apr 2002 18:36:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsznzubcdv.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0204231502320.31993-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1703HY-0008Ph-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 09:36:44 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0204231502320.31993-100000@kenzo.iwr.uni-heidelberg.de>
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

     > How big are the datagrams compared with the MTU ? With 32K
     > datagrams over Ethernet, you're talking about roughly a full Rx
     > ring worth of packets (32 is common for the Rx ring size)...

It has been a while ago (I've since mothballed the machine) but I saw
it on a Pentium 90 with only 8k write sizes. 4k was fine, 8k gave
avalanches.

    >> IOW: the client is just sitting there sending off ICMP
    >> messages, and never reading the reply.

     > Does the other side sees these messages ? If so, are there any
     > response messages sent out (but which don't make it back to the
     > client) ?

IIRC, yes, and the server was resending the datagrams. From the code,
it looks as if there is no attempt to stop loopback situations
occurring when this goes on:
i.e. resending an ICMP when the server resends a datagram which times
out again appears to be possible. This might be what was happening...

     > Down/up was on the sending or receiving/reassembling side ?

Down/up on the receiving/reassembling side.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
