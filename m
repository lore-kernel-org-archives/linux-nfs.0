Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:41499 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246Ab0HaQje convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 12:39:34 -0400
Subject: Re: mount.nfs: protocol fallback when server doesn't support TCP
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100831110024.68e8877d@notabene>
Date: Tue, 31 Aug 2010 12:38:09 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <EC686BD1-834D-4060-84E7-FBF0733B7ACA@oracle.com>
References: <20100826120635.4c3157bc@notabene> <659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com> <20100830103025.70d09ec8@notabene> <BC2D2164-0836-4DAC-99C5-C7BE23D3B163@oracle.com> <20100831110024.68e8877d@notabene>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 30, 2010, at 9:00 PM, Neil Brown wrote:

> On Mon, 30 Aug 2010 15:29:03 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Aug 29, 2010, at 8:30 PM, Neil Brown wrote:
>> 
>>> On Thu, 26 Aug 2010 10:51:23 -0400
>>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>> 
>>>> 
>>>> On Aug 25, 2010, at 10:06 PM, Neil Brown wrote:
>>>> 
>>> How about this:
>>> If nfs_try_mount_v4 return ECONNREFUSED we do a portmap lookup and see
>>> which versions and protocols are supported.
>>> If nothing is registered, or if any version support TCP, then we take the
>>> current approach or waiting and trying again on the assumption that the
>>> server is still starting up and wasn't quite ready yet when we got the
>>> ECONNREFUSED.
>>> However if UDP support is available but TCP isn't, and if the mount options
>>> don't specify a protocol, then fall back to v2v3.
>> 
>> That doesn't sound too bad.
> 
> Good.  Thanks.
> 
>> 
>>> So here is my second draft.  The 'verbose' results will be a bit confusing
>>> but I think the functionality is close to what I want - it just does the pmap
>>> lookups twice.
>>> 
>>> NeilBrown
>>> 
>>> 
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index 0241400..913b563 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -93,6 +93,7 @@ struct nfsmount_info {
>>> 	char			**extra_opts;	/* string for /etc/mtab */
>>> 
>>> 	unsigned long		version;	/* NFS version */
>>> +	unsigned long		proto;		/* protocol chosen */
>>> 	int			flags,		/* MS_ flags */
>>> 				fake,		/* actually do the mount? */
>>> 				child;		/* forked bg child? */
>>> @@ -625,6 +626,9 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
>>> 	if (!nfs_rewrite_pmap_mount_options(options))
>>> 		goto out_fail;
>>> 
>>> +	/* record which protocol was chosen */
>>> +	nfs_nfs_protocol(options, &mi->proto);
>> 
>> Don't see why this is necessary...?
>> 
>> The mount retry loop operates on a copy of the command line options; each iteration gets a fresh copy of the original options.  Maybe it's lunchtime and I'm hungry enough that I just don't understand how you are using mi->proto.
> 
> At the interesting moment when an NFSv4 attempt returned ECONNREFUSED we only
> want to try a V3 mount if it would use UDP (or UDP6 I guess).
> 
> The easiest way to determine this is to go through the motions with a 'fake'
> mount attempt and see what protocol ends up being used.
> mi->proto is used simply to pass the final decision back up to the caller so
> we can know what was decided.
> The string options which also would record this are not passed back up.
> 
> 
>> 
>>> +
>>> 	result = nfs_sys_mount(mi, options);
>>> 
>>> out_fail:
>>> @@ -762,6 +766,29 @@ static int nfs_try_mount(struct nfsmount_info *mi)
>>> 			errno = 0;
>>> 			result = nfs_try_mount_v4(mi);
>>> 			if (errno != EPROTONOSUPPORT) {
>>> +				/* If server only handles UDP, then v4 will have
>>> +				 * received ECONNREFUSED for TCP, so fall through
>>> +				 * to v3v2 which can try udp, but only if tcp
>>> +				 * wasn't explicitly requested
>>> +				 */
>>> +				if (errno == ECONNREFUSED) {
>>> +					unsigned long proto;
>>> +					if (nfs_nfs_protocol(mi->options, &proto) == 1 &&
>>> +					    proto == 0) {
>> 
>> Is the protocol setting loop-invariant?  Shouldn't you use mi->proto here?
> 
> This is happening before any call to nfs_try_mountv3v2 so mi->proto would not
> be set.  At this point we just want a quick look a the options to see if a
> protocol was specified.  If it was the fallback from v4 over tcp to v3 over
> udp would clearly be wrong and can be avoided.  So we really just want a
> temporary variable here to examine the options.
> Yes, it is a loop-invariant, but there would not be a lot to gain by making
> 'proto' a more global variable.

The context saved in the mount_info struct is probably not quite logically appropriate for storing temporary values across retry iterations.  That could be a pseudo-rationale for grabbing the command-line specified protocol value at the same time as the command-line specified NFS version, in nfs_validate_options(), before the retry loop starts.  Another rationale might be making the logic in here a little simpler (not that I'm complaining, just making an observation).

>> 
>>> +						/* OK to try different protocols. Lets see
>>> +						 * what portmap thinks.
>>> +						 */
>>> +						int oldfake = mi->fake;
>>> +						int res;
>>> +						mi->fake = 1;
>>> +						res = nfs_try_mount_v3v2(mi);
>> 
>> If you just want to probe the server's portmapper, I think you can use nfs_probe_bothports() directly.
>> 
> 
> Not quite.  You would need to wrap it in a loop over all addresses in
> md->address, and would need to worry about the mounthost option.  It seems
> easier to just call nfs_try_mount_v3v2 which already does this.

/me smacks forehead

Complexity that I guess we have to live with.  A comment that explains the oldfake hack would be helpful.

>>> +						mi->fake = oldfake;
>>> +						if (!res || mi->proto != IPPROTO_UDP)
>>> +							/* time out and try again */
>>> +							break;
>>> +					} else
>>> +						break;
>>> +				} else
>>> 				/* 
>>> 				 * To deal with legacy Linux servers that don't
>>> 				 * automatically export a pseudo root, retry
>>> 
>>> 
>> 
>> This is a lot of logic to stuff in here, where it is already fairly congested.  I would encourage you to move it to a helper function if that's practical.
>> 
> 
> That is a fairly common (and valid) complaint about my coding style.
> My post-hoc excuse is that I was going to clean it up once I got the logic
> sorted out properly.

Sorry for the nudge.

> Two observations I've made while exploring which are only tangential to the
> current issue:
> 
> 1/ if I give an invalid proto name
>          mount -o proto=fred .....
>    the mount command fails (as it should) but gives no error message.

Thanks for the report.  Does this occur with both a legacy glibc RPC build and a libtirpc-enabled build?

> 2/ The options saved in /etc/mtab does not include any automatically
>    determined options.  For mountport that is reasonable.  For proto that is
>    possibly justified though I am less sure, but for vers it seems wrong.
>    /etc/mtab needs to reccord if an unmount request shold be sent which
>    means it needs to know which of v2/3 or v4 was used.

When deciding what mount options should go in /etc/mtab, the guide I use is: if I want to reproduce the same behavior as when the original mount was done, what options would I put in the saved mount option string?  In this case, I think the NFS version setting ostensibly should be added.

However, when mount option negotiation is in effect, it becomes a little less clear.  Basically in that case, we should put in the options specified on the command line, and let the next mount command instantiation renegotiate if needed.

I suspect the problem here is that the logic that updates /etc/mtab assumes the legacy world where the file system type was the sole determinant of whether NFS version 4 is in use.  So the NFSv4 mtab updating code doesn't bother to stick a version option in when needed (the new "-t nfs vers=4" case).

This probably has some consequences for umount, since it decides whether to send a UMNT to the server based on what NFS version is listed in /etc/mtab.

-- 
chuck[dot]lever[at]oracle[dot]com




