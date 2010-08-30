Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:40287 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543Ab0H3Tay convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 15:30:54 -0400
Subject: Re: mount.nfs: protocol fallback when server doesn't support TCP
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100830103025.70d09ec8@notabene>
Date: Mon, 30 Aug 2010 15:29:03 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <BC2D2164-0836-4DAC-99C5-C7BE23D3B163@oracle.com>
References: <20100826120635.4c3157bc@notabene> <659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com> <20100830103025.70d09ec8@notabene>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 29, 2010, at 8:30 PM, Neil Brown wrote:

> On Thu, 26 Aug 2010 10:51:23 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Aug 25, 2010, at 10:06 PM, Neil Brown wrote:
>> 
>>> 
>>> Currently if the server doesn't support TCP (and so doesn't support NFSv4)
>>> we don't fall-back to NFSv3.  This is because 'ECONNREFUSED' isn't deemed to
>>> be a suitable error for falling back.  Rather we wait for about 2 minutes,
>>> then give up.
>>> 
>>> There is some justification for this:  ECONNREFUSED could just mean that the
>>> server isn't quite ready yet.
>>> 
>>> I'm not really sure what the best thing to do here would be.  We don't really
>>> want to try v3 and have fail only because it was just enough later that nfsd
>>> is now responding.
>>> 
>>> Maybe the ideal would be to do a portmap probe and only fall back to v3 if
>>> portmap confirm that v3 is supported and v4 isn't.
>>> 
>>> For now I just present this patch which allows fallback to v3 providing tcp
>>> wasn't explicitly requested.
>>> 
>>> Thoughts?
>> 
>> What are the risks of checking portmap in this case?  That seems like it would give a better chance of a desirable outcome.
> 
> True, I was just too lazy at the time.
> 
> How about this:
>  If nfs_try_mount_v4 return ECONNREFUSED we do a portmap lookup and see
>  which versions and protocols are supported.
>  If nothing is registered, or if any version support TCP, then we take the
>  current approach or waiting and trying again on the assumption that the
>  server is still starting up and wasn't quite ready yet when we got the
>  ECONNREFUSED.
>  However if UDP support is available but TCP isn't, and if the mount options
>  don't specify a protocol, then fall back to v2v3.

That doesn't sound too bad.

> So here is my second draft.  The 'verbose' results will be a bit confusing
> but I think the functionality is close to what I want - it just does the pmap
> lookups twice.
> 
> NeilBrown
> 
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 0241400..913b563 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -93,6 +93,7 @@ struct nfsmount_info {
> 	char			**extra_opts;	/* string for /etc/mtab */
> 
> 	unsigned long		version;	/* NFS version */
> +	unsigned long		proto;		/* protocol chosen */
> 	int			flags,		/* MS_ flags */
> 				fake,		/* actually do the mount? */
> 				child;		/* forked bg child? */
> @@ -625,6 +626,9 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
> 	if (!nfs_rewrite_pmap_mount_options(options))
> 		goto out_fail;
> 
> +	/* record which protocol was chosen */
> +	nfs_nfs_protocol(options, &mi->proto);

Don't see why this is necessary...?

The mount retry loop operates on a copy of the command line options; each iteration gets a fresh copy of the original options.  Maybe it's lunchtime and I'm hungry enough that I just don't understand how you are using mi->proto.

> +
> 	result = nfs_sys_mount(mi, options);
> 
> out_fail:
> @@ -762,6 +766,29 @@ static int nfs_try_mount(struct nfsmount_info *mi)
> 			errno = 0;
> 			result = nfs_try_mount_v4(mi);
> 			if (errno != EPROTONOSUPPORT) {
> +				/* If server only handles UDP, then v4 will have
> +				 * received ECONNREFUSED for TCP, so fall through
> +				 * to v3v2 which can try udp, but only if tcp
> +				 * wasn't explicitly requested
> +				 */
> +				if (errno == ECONNREFUSED) {
> +					unsigned long proto;
> +					if (nfs_nfs_protocol(mi->options, &proto) == 1 &&
> +					    proto == 0) {

Is the protocol setting loop-invariant?  Shouldn't you use mi->proto here?

> +						/* OK to try different protocols. Lets see
> +						 * what portmap thinks.
> +						 */
> +						int oldfake = mi->fake;
> +						int res;
> +						mi->fake = 1;
> +						res = nfs_try_mount_v3v2(mi);

If you just want to probe the server's portmapper, I think you can use nfs_probe_bothports() directly.

> +						mi->fake = oldfake;
> +						if (!res || mi->proto != IPPROTO_UDP)
> +							/* time out and try again */
> +							break;
> +					} else
> +						break;
> +				} else
> 				/* 
> 				 * To deal with legacy Linux servers that don't
> 				 * automatically export a pseudo root, retry
> 
> 

This is a lot of logic to stuff in here, where it is already fairly congested.  I would encourage you to move it to a helper function if that's practical.

-- 
chuck[dot]lever[at]oracle[dot]com




