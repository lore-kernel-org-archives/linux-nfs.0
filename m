Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:27956 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab0HZOwM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Aug 2010 10:52:12 -0400
Subject: Re: mount.nfs: protocol fallback when server doesn't support TCP
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100826120635.4c3157bc@notabene>
Date: Thu, 26 Aug 2010 10:51:23 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com>
References: <20100826120635.4c3157bc@notabene>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 25, 2010, at 10:06 PM, Neil Brown wrote:

> 
> Currently if the server doesn't support TCP (and so doesn't support NFSv4)
> we don't fall-back to NFSv3.  This is because 'ECONNREFUSED' isn't deemed to
> be a suitable error for falling back.  Rather we wait for about 2 minutes,
> then give up.
> 
> There is some justification for this:  ECONNREFUSED could just mean that the
> server isn't quite ready yet.
> 
> I'm not really sure what the best thing to do here would be.  We don't really
> want to try v3 and have fail only because it was just enough later that nfsd
> is now responding.
> 
> Maybe the ideal would be to do a portmap probe and only fall back to v3 if
> portmap confirm that v3 is supported and v4 isn't.
> 
> For now I just present this patch which allows fallback to v3 providing tcp
> wasn't explicitly requested.
> 
> Thoughts?

What are the risks of checking portmap in this case?  That seems like it would give a better chance of a desirable outcome.

> NeilBrown
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 0241400..fb8c108 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -762,6 +762,25 @@ static int nfs_try_mount(struct nfsmount_info *mi)
> 			errno = 0;
> 			result = nfs_try_mount_v4(mi);
> 			if (errno != EPROTONOSUPPORT) {
> +				/* If server only handles UDP, then v4 will have
> +				 * received ECONNREFUSED for TCP, so fall through
> +				 * to v3v2 which can try udp, but only if tcp
> +				 * wasn't explicitly requested
> +				 */
> +				if (errno == ECONNREFUSED) {
> +					static const char *nfs_proto_tbl[] = {
> +						"udp",
> +						"tcp",
> +						NULL
> +					};
> +					char *p;
> +
> +					if (po_rightmost(mi->options, nfs_proto_tbl) == 1)
> +						break;
> +					p = po_get(mi->options, "proto");
> +					if (p && strcmp(p, "tcp") == 0)
> +						break;

There are all kinds of things to worry about when looking for what protocol was specified.  For example, you should check for udp6 or tcp6 here (and of course, you shouldn't check for those if IPV6_SUPPORTED is not enabled).

utils/mount/network.c:nfs_nfs_protocol() does most or all of what you need.  It will also return zero if the user didn't specify a protocol, which is, I think, the case you're trying to detect here.

> +				} else
> 				/* 
> 				 * To deal with legacy Linux servers that don't
> 				 * automatically export a pseudo root, retry

-- 
chuck[dot]lever[at]oracle[dot]com




