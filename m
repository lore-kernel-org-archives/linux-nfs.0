From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: fragment flooding and self-configuring clients
Date: Thu, 27 Jun 2002 17:36:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200206271736.12310.trond.myklebust@fys.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E50D03F@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net,
 "'Benjamin LaHaise'" <bcrl@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17NbJo-00011G-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Jun 2002 08:36:24 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E50D03F@black.eng.netapp.com>
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

On Thursday 27 June 2002 07:06, Lever, Charles wrote:

> the real solution to dropped fragments, however, is to make the
> IP layer hold onto all fragments until it is sure it can send
> the whole packet.  IOW, drop only whole packets, not fragments.
> the code in ip_build_xmit_slow is somewhat opaque to me, so i
> haven't included a patch here.  however, i think fixing that
> code will go a long way towards making NFS over UDP on Linux
> clients more robust on high-end hardware.
>
> in fact, this issue may be the real reason your patch to send
> fragments in forward order improved performance in our testing.
> it appears to drop a whole packet if it can't allocate space
> for one or more fragments.

I will ask davem how he would feel about such a patch. In the case where 
MSG_DONTWAIT is set, the current code appears to be wasting bandwith by 
sending off message fragments that cannot ever be reassembled.

We don't even have to include the LIFO queueing that inverts the fragment 
sending order: just use a FIFO queue in order to delay the send until we've 
fragmented the entire message.

> the issue i have with the implementation you have chosen in
> the rpc_tweak patch is that the socket buffer size it computes
> is often too large.  for instance, why (server->rsize + 1024) ?
> the real size of a full-sized read request is probably closer to
> (server->rsize + 160).  then, after all the multiplication

Actually, the RPC code can in principle be around 600 bytes long. Don't 
forget, the authentication code alone can in principle be 408 bytes long 
(although AUTH_SYS is of course significantly shorter).
In addition, the socket code likes a bit of padding of its own. It needs to be 
able to split up skbs, juggle them around etc.

> in xprt_set_sockbufsize, it is possible to get an excessively
> large buffer size.  there is no cap for this value, and i'm
> sure there is a reasonable maximum.  on one of my systems, the
> computed value was over 3 megabytes.  might this cause some
> kind of data corruption if a buffer of that size can't actually
> be allocated?

I did an audit recently that suggested this would not be the case, but I may 
have overlooked something. davem too thought that it would be safe.

Cheers,
  Trond


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
