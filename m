From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 2/2] nfs(5): Clarify behavior of the mountproto=
  and proto= options
Date: Tue, 23 Sep 2008 12:41:14 -0400
Message-ID: <RTPCLUEXC1-PRDSzbAU000000cd@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080923161322.5119.20872.stgit@manray.1015granger.net>
 <20080923161641.5119.37034.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18404 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368AbYIWQms (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2008 12:42:48 -0400
In-Reply-To: <20080923161641.5119.37034.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
References: <20080923161322.5119.20872.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
 <20080923161641.5119.37034.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One other comment...

At 12:16 PM 9/23/2008, Chuck Lever wrote:
>Document the interaction between the mountproto= and the proto= mount
>options in a new subsection of nfs(5).
>
>Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>---
>
> utils/mount/nfs.man |   81 +++++++++++++++++++++++++++++++++++++++++++++++++++
> 1 files changed, 81 insertions(+), 0 deletions(-)
>
>diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>index b1037a8..48f2153 100644
>--- a/utils/mount/nfs.man
>+++ b/utils/mount/nfs.man
>@@ -831,6 +831,87 @@ and
> .B wsize
> can safely be allowed to default to the largest values supported by  
> both client and server, independent of the network's MTU size.
>+.SS "Interaction between the proto and mountproto options"
>+The Linux NFS client can use a different transport protocol for
>+contacting an NFS server's rpcbind service, its mountd service,
>+its NLM service, and its NFS service.
>+The exact transport protocols employed by the Linux NFS client for
>+each mount point depends on the settings of the transport protocol
>+mount options, which include
>+.BR proto ,
>+.BR mountproto ,
>+.BR udp ", and " tcp .
>+.P
>+The NSM protocol uses the UDP transport
>+no matter what transport specific options are specified.

This actually isn't true - in fact the client NSM by default listens on
both UDP and TCP, as can be seen with rpcinfo -p.

What is true is that the vast majority of NFS servers call back on UDP,
and if this fails, there is no indication at the client whatsoever.

So the text should perhaps say "NFS servers typically choose UDP for the
NSM protocol; the client in any case accepts both UDP and TCP."

Tom.


>+The NFSACL protocol shares the same RPC transport as the main NFS
>+service.
>+.P
>+If no transport protocol options are specified, the Linux NFS client
>+uses UDP to contact the server's mountd service, and TCP to
>+contact its NLM and NFS services by default.
>+.P
>+UDP is a good choice for contacting the mountd server since most
>+common NFS servers support UDP for mountd, UDP generates less network
>+traffic, and UDP does not leave extra ports in TIME_WAIT after the
>+mountd request is complete.
>+However, a reliable stream transport such as TCP is a good choice for
>+NFS and NLM because these must handle large requests and must be
>+immune to network problems that might cause RPC requests to be lost.
>+.P
>+If the server does not support these transports for these services, the
>+.BR mount (8)
>+command attempts to discover what the server supports, and then retries
>+the mount request once using the discovered transport protocols.
>+If the server does not advertise any transport supported by the client
>+or is misconfigured, the mount request fails.
>+If the
>+.B bg
>+option is in effect, the mount command backgrounds itself and continues
>+to attempt the specified mount request.
>+.P
>+When the
>+.B proto
>+option, the
>+.B udp
>+option, or the
>+.B tcp
>+option is specified but the
>+.B mountproto
>+option is not, the specified transport is used to contact
>+both the server's mountd service and for the NLM and NFS services.
>+.P
>+If the
>+.B mountproto
>+option is specified but none of the
>+.BR proto ", " udp " or " tcp
>+options are specified, then the specified transport is used for the
>+initial mountd request, but the mount command attempts to discover
>+what the server supports for the NFS protocol, preferring TCP if
>+both transports are supported.
>+.P
>+If both the
>+.BR mountproto " and " proto
>+(or
>+.BR udp " or " tcp )
>+options are specified, then the transport specified by the
>+.B mountproto
>+option is used for the initial mountd request, and the transport
>+specified by the
>+.B proto
>+option (or the
>+.BR udp " or " tcp " options)"
>+is used for NFS, no matter what order these options appear.
>+No automatic service discovery is performed if these options are
>+specified.
>+.P
>+If any of the
>+.BR proto ", " udp ", " tcp ", "
>+or
>+.B mountproto
>+options are specified more than once on the same mount command line,
>+then the value of the rightmost instance of each of these options
>+takes effect.
> .SH "DATA AND METADATA COHERENCE"
> Some modern cluster file systems provide
> perfect cache coherence among their clients.
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

