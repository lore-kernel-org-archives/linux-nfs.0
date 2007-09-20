From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 00/19] NFS/RDMA client support
Date: Thu, 20 Sep 2007 10:57:32 -0400
Message-ID: <EXNANE010ZkfzDskqC500000565@exnane01.hq.netapp.com>
References: <EXNANE01TIVvLVKi3s1000004af@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYNWv-0001H4-Cs
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 08:01:25 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IYNWx-0004Dt-MQ
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 08:01:30 -0700
In-Reply-To: <EXNANE01TIVvLVKi3s1000004af@exnane01.hq.netapp.com>
References: <EXNANE01TIVvLVKi3s1000004af@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Trond - I believe the NFS/RDMA client patchset is ready for kernel
inclusion. The one open issue of transport naming as integers, is
compatible with the existing kernel code and user binaries. So, while
using a string is better long-term, there are a bunch of issues and
a fairly large patch set to get there. Since transport naming isn't
an NFS/RDMA issue, I feel they should be considered separately.

Do you agree? If there are any remaining issues in the patchset
already sent, I'm happy to address them.

Tom.

At 01:41 PM 9/10/2007, Talpey, Thomas wrote:
>The following 19 messages contain a patch series to implement the
>fully integrated NFS/RDMA client into kernel 2.6.23-rc5 + NFS_ALL.
>They also integrate cleanly into the current <git://linux-nfs.org/nfs-2.6>.
>
>I would like to see them considered for inclusion into 2.6.24, most
>especially the first 14 which are purely infrastructure related.
>
>The patches are sequenced into the following functional groupings:
>
>01-02 implement RPCBIND netid's in each transport, instead of being
>decided by the rpcbind client before sending. This change also corrects
>the problem that IPv6 netid's were not supported.
>
>03-05 "invert" the parsing of NFS mount options in kernel to use the
>existing kernel-private nfs_parsed_mount_options structure for NFS[234],
>instead of continuing to use the legacy nfs_mount_data in both kernel
>and user space. Coupled with the new string-based NFS mount API, this
>allows extension of NFS mount options with no required changes to user
>space. It's needed for adding RDMA, but may also be useful for other
>NFS-related projects (such as fscache?).
>
>06 adds a flag to the xdrbuf to permit the rdma transport to marshal
>data appropriately.
>
>07-09 implement dynamic RPC transport registration, and logically
>reorganize the socket support as built-in TCP/UDP transports. These
>patches originated with Chuck Lever's transport switch work.
>
>10-11 rearrange a few sockets-specific RPC transport definitions into
>their own logical components. This is in preparation for adding the first
>new RPC transport.
>
>12-14 change the way RPC transports are selected from a raw IP
>protocol to a new RPC-layer identifier. Also #14 allows NFS to
>accurately print the "proto=" argument via /proc/mounts.
>
>15-19 implement the new RPC RDMA transport:
>
> 15 declares the RPC/RDMA protocol, RPC RDMA transport definitions,
>and configuration option.
>
> 16 adds support for the "-o rdma" option to string-based NFS mounts
>
> 17 adds the core RPC RDMA transport switch implementation. It has
>stubs for the RDMA API below it, and the RPC/RDMA protocol marshaling
>used when sending and receiving RPC messages.
>
> 18 implements the RPC message handling and connection management.
>
> 19 implements the kernel RDMA verbs interface.
>
>Since this version is fully integrated with the new string-based NFS
>kernel mount API, it requires the latest nfs-utils mount.nfs command,
>which must be invoked with the new "-i" flag. Additionally, until the
>server implements the necessary rpcbindv3 support, the RDMA port
>number must be provided in the mount command line. Currently, most
>NFS/RDMA servers are listening on 2050, this is likely to change.
>
>	mount -i [-t nfs4] -o rdma,port=2050 server:/filesystem /mountpoint
>
>The core net/sunrpc/xprtrdma files are little changed from the July
>RFC Patches, except to fit into the above infrastructure, fix two
>issues in corner case RDMA chunk marshaling, and to correct kernel
>coding style nits.
>
>Comments on any and all issues are welcome.
>
>Tom.
>
>-------------------------------------------------------------------------
>This SF.net email is sponsored by: Microsoft
>Defy all challenges. Microsoft(R) Visual Studio 2005.
>http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
