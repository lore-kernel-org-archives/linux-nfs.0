Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33005 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755532Ab0IGBcd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Sep 2010 21:32:33 -0400
Date: Tue, 7 Sep 2010 11:32:25 +1000
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: mount.nfs: protocol fallback when server doesn't support TCP
Message-ID: <20100907113225.4a018ba3@notabene>
In-Reply-To: <EC686BD1-834D-4060-84E7-FBF0733B7ACA@oracle.com>
References: <20100826120635.4c3157bc@notabene>
	<659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com>
	<20100830103025.70d09ec8@notabene>
	<BC2D2164-0836-4DAC-99C5-C7BE23D3B163@oracle.com>
	<20100831110024.68e8877d@notabene>
	<EC686BD1-834D-4060-84E7-FBF0733B7ACA@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 31 Aug 2010 12:38:09 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:


> >> 
> >>> +						/* OK to try different protocols. Lets see
> >>> +						 * what portmap thinks.
> >>> +						 */
> >>> +						int oldfake = mi->fake;
> >>> +						int res;
> >>> +						mi->fake = 1;
> >>> +						res = nfs_try_mount_v3v2(mi);
> >> 
> >> If you just want to probe the server's portmapper, I think you can use nfs_probe_bothports() directly.
> >> 
> > 
> > Not quite.  You would need to wrap it in a loop over all addresses in
> > md->address, and would need to worry about the mounthost option.  It seems
> > easier to just call nfs_try_mount_v3v2 which already does this.
> 
> /me smacks forehead
> 
> Complexity that I guess we have to live with.  A comment that explains the oldfake hack would be helpful.

And often trying to write such a comment can make it clear why the code was a
bad idea in the first place.... :-)

Rather than write a comment I wouldn't believe myself, here is something
quite different - my third draft.
This is on top of the nice tidy-up patches you posted earlier.

It uses nfs_getport to make very focussed requests to portmap.

Two things I'm still not really sure about:

1/ RDMA.  How does that interact with fallback.  Do we only support v4 over
   RDMA?  That would be nice was we could simply avoid fallback in that case.

2/ IPv6.  I should possibly be checking if v3v2 are available via UDP6 as well
   as UDP - and similarly if v4 has become available via TCP6?? Or is that
   all magically handled somewhere under the hood?

Thanks,
NeilBrown

>From 60dae9b9c14869ae630db683e2524ad230064b19 Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Tue, 7 Sep 2010 11:23:02 +1000
Subject: [PATCH] mount: correctly handle fallback for  ECONNREFUSED during mount attempt.

If we get ECONNREFUSED when attempting a v4 mount, it could be that
the server just isn't ready yet (the current assumption) or it could
be that the server only support UDP - and thus only v3/v2.  The latter
possibility isn't handled currently.

So if we get ECONNREFUSED when fallback is an option, check with
portmap/rpcbind to see if it could be that case that v2/v3 are
supported over UDP, and v4 still is not.  In that case, fall back to v2v3.

I'm not at all sure if IPv6 possibilities are RDMA are handled correctly..

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 9e29a19..5ebcf3e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -750,6 +750,7 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
 {
 	unsigned long protocol;
 	int result;
+	struct addrinfo *ai;
 
 	/*
 	 * If UDP was requested from the command line, try
@@ -796,6 +797,33 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
 		/* Linux servers prior to 2.6.25 may return
 		 * EPERM when NFS version 4 is not supported. */
 		goto fall_back;
+	case ECONNREFUSED:
+		/* Either the server doesn't accept TCP connections,
+		 * or it just isn't quite ready yet.
+		 * In the first case, fall back to v3v2, in the second
+		 * return failure - as this isn't a permanent error
+		 * the attempt will be retried.
+		 * To determine which, we need to check with portmap/rpcbind.
+		 * If v2 or v3 are supported on UDP, but v4 isn't on TCP then fall-back.
+		 */
+		for (ai = mi->address; ai != NULL; ai = ai->ai_next) {
+			if (nfs_getport(ai->ai_addr, ai->ai_addrlen,
+					NFS_PROGRAM, 3, IPPROTO_UDP) != 0 ||
+			    nfs_getport(ai->ai_addr, ai->ai_addrlen,
+					NFS_PROGRAM, 2, IPPROTO_UDP) != 0) {
+				if (nfs_getport(ai->ai_addr, ai->ai_addrlen,
+						NFS_PROGRAM, 4, IPPROTO_TCP) != 0) {
+					/* v4 support is almost online, wait for it. */
+					errno = ECONNREFUSED;
+					return result;
+				} else
+					/* v2/v3 is supported, but v4 isn't, fall_back */
+					goto fall_back;
+			}
+		}
+		/* portmap is not responding yet either, so just try again */
+		errno = ECONNREFUSED;
+		return result;
 	default:
 		return result;
 	}
