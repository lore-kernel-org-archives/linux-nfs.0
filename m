From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: fragment flooding and self-configuring clients
Date: Wed, 26 Jun 2002 22:06:18 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50D03F@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, "'Benjamin LaHaise'" <bcrl@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17NRUJ-0005ZY-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Jun 2002 22:06:35 -0700
To: "Trond Myklebust (E-mail)" <trond.myklebust@fys.uio.no>
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

hi trond-

somewhat rambling e-mail here.

i've been studying the RPC and network layers to find out what
might be causing the strange network floods between late Linux
clients and fast servers.  i discovered something interesting
today.

when the client's IP layer is fragmenting an IP packet that is
larger than the NIC's MTU, it can exhaust the socket's output
buffer.  when this happens, fragments that have been processed
so far have already been sent to the receiver, but no more
fragments are sent -- the remaining parts of that IP packet are
dropped.  thus, under load, the client prodigiously produces
partially fragmented IP packets.  this is one way a fast client
can overflow a server's IP reassembly queue.

i generated a histogram to see how often packets are lost
because the client transmits only some of a fragmented IP
packet.  i ran a 20MB write benchmark 4 times with UDP and
32K wsize, and found that fragments at offset 32560 (the
first fragment in an IP packet to be sent) occurred 4001
times in my trace, but the last fragment in a packet (the
one that actually contains the IP header and RPC request)
occurred only 2950 times.  :-)  by visual inspection alone,
i found several cases where the client sent the first 10 to
12 fragments of a request, then simply started sending the
next request.

a partial workaround for this is to use a larger pair of
socket buffers.  you already have a patch that does this;
see:

   http://www.fys.uio.no/~trondmy/src/2.4.19-pre8/linux-2.4.19-11-rpc_tweaks.dif

this is a good idea: it makes the client more self-configuring
(as we have discussed before).  it chooses the correct socket
buffer size without any fiddling on the part of a local human
being.  i think this patch should be polished up and presented
for inclusion as soon as it can be, because it addresses a
real issue, and helps with this fragmentation problem, too.

the real solution to dropped fragments, however, is to make the
IP layer hold onto all fragments until it is sure it can send
the whole packet.  IOW, drop only whole packets, not fragments.
the code in ip_build_xmit_slow is somewhat opaque to me, so i
haven't included a patch here.  however, i think fixing that
code will go a long way towards making NFS over UDP on Linux
clients more robust on high-end hardware.

in fact, this issue may be the real reason your patch to send
fragments in forward order improved performance in our testing.
it appears to drop a whole packet if it can't allocate space
for one or more fragments.

comments?  maybe we should audit the RPC layer and network
layer to be sure that any random early drop doesn't cause
unwanted consequences.

the issue i have with the implementation you have chosen in
the rpc_tweak patch is that the socket buffer size it computes
is often too large.  for instance, why (server->rsize + 1024) ?
the real size of a full-sized read request is probably closer to
(server->rsize + 160).  then, after all the multiplication
in xprt_set_sockbufsize, it is possible to get an excessively
large buffer size.  there is no cap for this value, and i'm
sure there is a reasonable maximum.  on one of my systems, the
computed value was over 3 megabytes.  might this cause some
kind of data corruption if a buffer of that size can't actually
be allocated?

        -- Chuck Lever
--
personal:  <chucklever@bigfoot.com>
corporate: <cel@netapp.com>


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
