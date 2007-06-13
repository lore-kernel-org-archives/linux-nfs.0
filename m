From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Performance tuning on modern 2.6 series kernels
Date: Wed, 13 Jun 2007 14:58:13 -0400
Message-ID: <1181761093.6151.45.camel@heimdal.trondhjem.org>
References: <906723.78703.qm@web63902.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Bill Johnstone <beejstone3@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyY2u-0003AA-TV
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 11:58:21 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19a8hb4SYWCsY4p2uefpEcY560wMLBn3VQ=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HyY2s-00010L-Ty
	for nfs@lists.sourceforge.net; Wed, 13 Jun 2007 11:58:22 -0700
In-Reply-To: <906723.78703.qm@web63902.mail.re1.yahoo.com>
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

On Wed, 2007-06-13 at 10:45 -0700, Bill Johnstone wrote:
> Hello all.
> 
> I've been trying to understand performance tuning for NFSv3 on Linux
> 2.6 kernels (say 2.6.20 and up), and I just wound up uncertain, with a
> lot of questions.  Additionally, the Linux-NFS documentation for
> performance tuning at http://nfs.sourceforge.net/nfs-howto/ar01s05.html
> has a lot of discussion regarding 2.4 series kernels, which doesn't
> really seem that relevant these days.  It would be great if there was
> more discussion of 2.6-related information (if so desired, I could
> submit some changes to the docs based on what I hear back).  Anyway,
> here's what I would really appreciate some clarification on:
> 
> 1. TCP vs. UDP.  Assuming a high-bandwidth switched network, with
> enough disk and network bandwidth on the storage server, and
> rsize/wsize (for both) less than the MTU, UDP should have less overhead
> and be faster, than TCP, correct?

Only if the network is reliable. On lossy networks, TCP is infinitely
preferable.

> 2. Large rsize/wsize, and TCP vs. UDP again.  I understand that if the
> rsize/wsize is larger than the MTU, a UDP packet containing NFS
> read/write data will be fragmented into multiple packets.  However, all
> the documentation in this cases seems to imply that even though the
> same MTU restriction applies to TCP, TCP will be faster in this case
> than the fragmented UDP.  Why is this?  Doesn't TCP need to "fragment"
> the NFS payload as well?

Yes, but it doesn't need to retransmit the entire message if just one
fragment gets lost. Normally, it will just retransmit the one fragment.

> 3. Socket buffers.  Many references mention changing
> /proc/sys/net/core/{r,w}mem_default and
> /proc/sys/net/core/{r,w}mem_max
> but documents such as NetApp's "Using the Linux NFS Client with Network
> Appliance Filers" ( http://www.netapp.com/library/tr/3183.pdf ) mention
> that this is not necessary in 2.6 kernels, as they "auto-tune" socket
> buffers.  However, even if we needn't change the default values, is
> there any benefit to increasing the rmem_max / wmem_max parameters?

No. The RPC layer overrides them.

> 4. tcp_window_scaling, tcp_timestamps, and tcp_sack .  There is an IBM
> Linux NFS performance tuning article at
> http://www.ibm.com/developerworks/eserver/library/es-033104.html which
> mentions turning off all three of these features, and presumaby the
> tcp_window_scaling causes them to see an effective MSS less than what
> they get without it.  Is there merit to turning these features off
> today, on modern 2.6 kernels?

Those were in a section on "Web applications", not NFS AFAICS. Their
main reason for turning off window scaling is presumably to work around
the "broken router" issue??? (see http://lwn.net/Articles/92727/)
Otherwise, given their choices of tcp_rmem/tcp_wmem/tcp_mem, the
decision to turn off window scaling seems very odd...

See http://www.psc.edu/networking/projects/tcptune/ for a better
explanation of these 3 parameters.

NFS will usually want to allow receive buffers of > 64k, so you are
probably better off leaving window scaling on.

tcp_timestamps should probably also be left on, since you really do want
good estimation of the RTT and protection against sequence number
wraparound.

Finally, you should probably keep SACK on too if you are using window
scaling.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
