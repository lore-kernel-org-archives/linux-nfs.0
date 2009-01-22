From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH:  Support binding to a local IPv4 address when mounting
 a server.
Date: Wed, 21 Jan 2009 21:35:35 -0800
Message-ID: <497805A7.4070205@candelatech.com>
References: <4977C580.4040805@candelatech.com> <633CA802-DD5A-4082-B771-C524D367241F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60354 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbZAVFfp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2009 00:35:45 -0500
In-Reply-To: <633CA802-DD5A-4082-B771-C524D367241F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> A handful of generic comments.
>
> 1.  This needs to be broken into smaller patches before submission; 
> preferably before you submit another version for review.  Take a look 
> at the linux-nfs@vger.kernel.org archives to see how we handle large 
> changes like this.
>
> 2.  You should support local addresses only in the text-based path 
> (utils/mount/stropts.c) and not in the legacy paths 
> (utils/mount/nfs[4]mount.c).  I don't think we're ever going to allow 
> a version 7 of the mount data structure.
I could remove the version 7 data field, but what about the other code 
that creates
sockets for 'pinging' nfs daemons and such?   Is that code deprecated now?

If nothing else, it looks like "probe_bothports" needs a client-addr to 
pass on
to methods it calls, and so forth.  That means that other code that 
calls those
methods needs to be updated, and thus my huge repetitive patch.

> 3.  There are some umount-related changes coming up for IPv6 that will 
> touch the umount paths here; that may require some changes in your 
> modifications.
That should be fine.   I tried to make my current patch friendly for 
IPv6 and want to support local
IPv6 binding as well.
>
> 4.  This needs to have support for a new mount option in the kernel 
> (not a command-line option to the mount.nfs command, as you have 
> implemented) to handle passing the address to the kernel.
I think I already have this ready in the kernel, but I've been using the 
version 7 field to pass
in data using mount.nfs.    Can you give an example of a user-space 
command that would use the
new mount option as you suggest?  Do you do /etc/fstab any different for 
instance?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


