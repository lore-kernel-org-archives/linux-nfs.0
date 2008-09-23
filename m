From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 1/2] nfs(5): Replace the term "netid" in mount
  option descriptions
Date: Tue, 23 Sep 2008 12:30:29 -0400
Message-ID: <RTPCLUEXC1-PRDC8wSA000000ca@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080923161322.5119.20872.stgit@manray.1015granger.net>
 <20080923161636.5119.54434.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5935 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbYIWQbn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2008 12:31:43 -0400
In-Reply-To: <20080923161636.5119.54434.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
References: <20080923161322.5119.20872.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
 <20080923161636.5119.54434.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To be pedantic, identifiying this field as a "prot" may be just as
misleading. For example "rdma" (which isn't mentioned btw ;-) )
can employ tcp - iWARP adapters do this.

I think instead that the proto= field simply names the "transport"
rather than "netid" or "prot". Also, I think "prot" is much too easily
mistaken for "port".

So I suggest changing the example to "proto=transport", and deleting
the word "protocol" in the text, simply leaving "the transport used by
NFS to transmit..."

Tom.

At 12:16 PM 9/23/2008, Chuck Lever wrote:
>Mike Eisler noted that the use of the term "netid" in the descriptions
>of the "proto=" option is not appropriate, since Linux does not allow
>"udp6" or "tcp6".
>
>Remove the term "netid" from nfs(5).
>
>Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>---
>
> utils/mount/nfs.man |   12 ++++++------
> 1 files changed, 6 insertions(+), 6 deletions(-)
>
>diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>index 0fc5079..b1037a8 100644
>--- a/utils/mount/nfs.man
>+++ b/utils/mount/nfs.man
>@@ -411,10 +411,10 @@ for mounting the
> .B nfs
> file system type.
> .TP 1.5i
>-.BI proto= netid
>+.BI proto= prot
> The transport protocol used by the NFS client
> to transmit requests to the NFS server for this mount point.
>-.I netid
>+.I prot
> can be either
> .B udp
> or
>@@ -489,11 +489,11 @@ or the server's mountd service is not available 
>on the advertised port.
> This option can be used when mounting an NFS server
> through a firewall that blocks the rpcbind protocol.
> .TP 1.5i
>-.BI mountproto= netid
>+.BI mountproto= prot
> The transport protocol used by the NFS client
> to transmit requests to the NFS server's mountd service when performing
> this mount request, and when later unmounting this mount point.
>-.I netid
>+.I prot
> can be either
> .B udp
> or
>@@ -638,10 +638,10 @@ for mounting the
> .B nfs4
> file system type.
> .TP 1.5i
>-.BI proto= netid
>+.BI proto= prot
> The transport protocol used by the NFS client
> to transmit requests to the NFS server for this mount point.
>-.I netid
>+.I prot
> can be either
> .B udp
> or
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

