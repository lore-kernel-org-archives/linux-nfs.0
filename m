From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 10/10] svcrdma: Documentation update for the FastReg
	memory model
Date: Wed, 24 Sep 2008 17:21:02 -0400
Message-ID: <20080924212102.GD10841@fieldses.org>
References: <1221564879-85046-2-git-send-email-tom@opengridcomputing.com> <1221564879-85046-3-git-send-email-tom@opengridcomputing.com> <1221564879-85046-4-git-send-email-tom@opengridcomputing.com> <1221564879-85046-5-git-send-email-tom@opengridcomputing.com> <1221564879-85046-6-git-send-email-tom@opengridcomputing.com> <1221564879-85046-7-git-send-email-tom@opengridcomputing.com> <1221564879-85046-8-git-send-email-tom@opengridcomputing.com> <1221564879-85046-9-git-send-email-tom@opengridcomputing.com> <1221564879-85046-10-git-send-email-tom@opengridcomputing.com> <1221564879-85046-11-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46516 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751034AbYIXVVE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 17:21:04 -0400
In-Reply-To: <1221564879-85046-11-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 16, 2008 at 06:34:39AM -0500, Tom Tucker wrote:
> This patch adds security related documentation to the nfs-rdma.txt file
> that describes the memory registration model, the potential security
> exploits, and compares these exploits to a similar threat when using TCP
> as the transport.

Thanks for doing this.

> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  Documentation/filesystems/nfs-rdma.txt |   66 ++++++++++++++++++++++++++++++++
>  1 files changed, 66 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/filesystems/nfs-rdma.txt b/Documentation/filesystems/nfs-rdma.txt
> index 44bd766..41f0fb2 100644
> --- a/Documentation/filesystems/nfs-rdma.txt
> +++ b/Documentation/filesystems/nfs-rdma.txt
> @@ -269,3 +269,69 @@ NFS/RDMA Setup
>      the "proto" field for the given mount.
>  
>    Congratulations! You're using NFS/RDMA!
> +
> +Security
> +--------
> +
> +  NFSRDMA exploits the RDMA capabilities of the IB and iWARP
> +  transports to more efficiently exchange RPC data between the client
> +  and the server. This section discusses the security implications of
> +  the exchange of memory information on the wire when the wire may be
> +  monitorable by an untrusted application. The identifier that
> +  encapsulates this memory information is called an RKEY.
> +
> +  A principal exploit is that a node listening on a mirror port of a
> +  switch

There are probably always other ways to do trick the switch into sending
an attacker some of the traffic.  It might be simpler just to say "a
node on the local network".

> +  could snoop RDMA packets containing RKEY and then forge a
> +  packet with this RKEY to write and/or read the memory of the peer to
> +  which the RKEY referred.
> +
> +  The NFSRDMA protocol is defined such that a) only the server
> +  initiates RDMA, and b) only the client's memory is exposed via
> +  RKEY. This is why the server reads to fetch RPC data from the client
> +  even though it would be more efficient for the client to write the
> +  data to the server's memory. This design goal is not entirely
> +  realized with iWARP, however, because the RKEY (called an STag on
> +  iWARP) for the data sink of an RDMA_READ is actually placed on the
> +  wire, and this RKEY has Remote Write permission. This means that the
> +  server's memory is exposed by virtue of having placed the RKEY for
> +  it's local memory on the wire in order to receive the result of the

s/it's/its/

> +  RDMA_READ.
> +
> +  By contrast, IB uses an opaque transaction ID# to associate the
> +  READ_RPL with the READ_REQ and the data sink of an READ_REQ does not
> +  require remote access. That said, the byzantine node in question
> +  could forge a packet with this transaction ID and corrupt the target
> +  memory, however, the scope of the exploit is bounded to the lifetime
> +  of this single RDMA_READ request and to the memory mapped by the
> +  data sink of the READ_REQ.
> +
> +  The newer RDMA adapters (both iWARP and IB) support "Fast Memory
> +  Registration". This capability allows memory to be quickly
> +  registered (i.e. made available for remote access) and de-registered
> +  by submitting WR on the SQ. These capabilities provide a mechanism
> +  to reduce the exposure discused above by limiting the scope of the
> +  exploit. The idea is to create an RKEY that only maps the single RPC
> +  and whose effective lifetime is only the exchange of this single
> +  RPC. This is the default memory model that is employed by the server
> +  when supported by the adapter and by the client when the
> +  rdma_memreg_strategy is set to 6. Note that the client and server
> +  may use different memory registration strategies, however,
> +  performance is better when both the client and server use the
> +  FastReg memory registration strategy.
> +
> +  This approach has two benefits, a) it restricts the domain of the
> +  exploit to the memory of a single RPC, and b) it limits the duration
> +  of the exploit to the time it takes to satisfy the RDMA_READ.
> +
> +  It is arguable that a one-shot STag/RKEY is no less secure than RPC
> +  on the TCP transport. Consider that the exact same byzantine
> +  application could more easily corrupt TCP RPC payload by simply
> +  forging a packet with the correct TCP sequence number -- in fact
> +  it's easier than the RDMA exploit because the RDMA exploit requires
> +  that you correctly forge both the TCP packet and the RDMA
> +  payload. In addition the duration of the TCP exploit is the lifetime
> +  of the connection, not the lifetime of a single WR/RPC data transfer.
> +
> +  So if you buy the argument above, RDMA on IB or iWARP using Fast Reg
> +  is no less secure than TCP.

I'd leave out the first seven words of that last sentence on the grounds
that it's implicit....

This explanation is helpful, thanks.  It would also be helpful if we
could boil down the advice to just a sentence or two for the busy admin.
Something like:  unless you have card XYZ and kernel 2.6.y, do *not* use
rdma on a network where you cannot trust every machine....

And better at some point might be to allow nfs-utils to automatically
check for that situation, and/or just to drop support for anything that
can't provide at least a tcp/auth_unix-like security model.

--b.
