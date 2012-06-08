Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp10.mail.sp.isp-net.nl ([217.149.192.65]:42403 "EHLO
	smtp10.mail.sp.isp-net.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964826Ab2FHUv7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 16:51:59 -0400
Message-ID: <4FD265E9.3030309@xmsnet.nl>
Date: Fri, 08 Jun 2012 22:51:53 +0200
From: Hans de Bruin <jmdebruin@xmsnet.nl>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: nfsroot client will not start firefox or thunderbird from 3.4.0
 nfsserver
References: <4FC3F9F6.7010107@xmsnet.nl>
In-Reply-To: <4FC3F9F6.7010107@xmsnet.nl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/29/2012 12:19 AM, Hans de Bruin wrote:
> I just upgraded my home server from kernel 3.3.5 to 3.4.0 and ran into
> some trouble. My laptop, a nfsroot client, will not run firefox and
> thunderbird anymore. When I start these programs from an xterm, the
> cursor goes to the next line and waits indefinitely.
>

I have bisected this to


commit f3f8014862d813cca81a597c83bd1dbf0fb2b8f6
Author: Jeff Layton <jlayton@redhat.com>
Date:   Wed Mar 21 09:52:07 2012 -0400

     nfsd: add the infrastructure to handle the cld upcall

     ...and add a mechanism for switching between the "legacy" tracker and
     the new one. The decision is made by looking to see whether the
     v4recoverydir exists. If it does, then the legacy client tracker is
     used.

There are two buts. First git will not revert this, so I can not confirm 
this as the bad commit. Seceond, the previous step in the bisect 
resulted in the client not being able to start X at all:

The bisect step before that:

commit 813fd320c16691eac508fe350b4ee7362c6c4a56
Author: Jeff Layton <jlayton@redhat.com>
Date:   Wed Mar 21 09:52:08 2012 -0400

     nfsd: add notifier to handle mount/unmount of rpc_pipefs sb

     In the event that rpc_pipefs isn't mounted when nfsd starts, we
     must register a notifier to handle creating the dentry once it
     is mounted, and to remove the dentry on unmount.



The tail of my bisect log

# bad: [cc27e0d407021a278d08c1952f5af4ab38c49eda]
nfsd: don't allow legacy client tracker init for anything but init_net
git bisect bad cc27e0d407021a278d08c1952f5af4ab38c49eda
# good: [ab4684d1560f8d77f6ce82bd3f1f82937070d397]
NFSD: Fix nfs4_verifier memory alignment
git bisect good ab4684d1560f8d77f6ce82bd3f1f82937070d397
# good: [b3537c35c21f0e6750aa8bd786949b55509c6d0d]
sunrpc: create nfsd dir in rpc_pipefs
git bisect good b3537c35c21f0e6750aa8bd786949b55509c6d0d
# good: [0ab628d856a63d63b47307b09851d1e955c706ac]
nfsd: add a header describing upcall to nfsdcld
git bisect good 0ab628d856a63d63b47307b09851d1e955c706ac
# bad: [813fd320c16691eac508fe350b4ee7362c6c4a56]
nfsd: add notifier to handle mount/unmount of rpc_pipefs sb
git bisect bad 813fd320c16691eac508fe350b4ee7362c6c4a56
# bad: [f3f8014862d813cca81a597c83bd1dbf0fb2b8f6]
nfsd: add the infrastructure to handle the cld upcall
git bisect bad f3f8014862d813cca81a597c83bd1dbf0fb2b8f6


-- 
Hans
