Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675AbaHMTKC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2014 15:10:02 -0400
Message-ID: <53EBB805.6070006@RedHat.com>
Date: Wed, 13 Aug 2014 15:09:57 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christian Seiler <christian@iwakd.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] libnfsidmap: respect Nobody-User/Nobody-Group
References: <1401794264-3975-1-git-send-email-christian@iwakd.de> <53EB962C.5000001@RedHat.com> <603dd17035c81999c99b9020b65d8768@iwakd.de>
In-Reply-To: <603dd17035c81999c99b9020b65d8768@iwakd.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/13/2014 01:45 PM, Christian Seiler wrote:
> No problem. To be honest, I completely forgot about this patch
> myself, because I wrote this patch when I tried to switch from
> idmapd to nfsidmap, but after I had some problems with that, I
> kind of switched back to idmapd, and then kind of put the whole
> thing to the back of my mind.
> 
> But perhaps you can give me a couple of pointers on how to
> best debug the issue I had with nfsidmap:
> 
>  - nsswitch translation for idmapping, nss_ldapd
I'm not sure what you are asking...

>  - nfsv4 sec=krb5 mount (mounted via autofs)
So your saying krb5 v4 mounts don't work via autofs and
its because idmapping??

>  - no krb5 ticket: ls doesn't even work (permission denied)
>    (this is expected, not a bug)
>  - with krb5 ticket: ls -l shows correct directory contents,
>    with correct user/group ownership (translation nfs4 ->
>    uid/gid via nfsidmap and then uid/gid -> local names via
>    getpwnam works)
And what's the problem?

>  - accessing files owned by myself but that are not group/other
>    readable doesn't work (permission denied)
hmm... this sound like a bug...

>  - writing to files / directories on which I have write
>    permission (but no other write permission) doesn't work
Is the execute bit on? 
>  - nfsv4 sec=sys mounts don't have this problem
> 
> To me this appears to be a problem that while uids/gids are
> correctly mapped when getting data from the server, they are
> not mapped properly when sending requests to the server, so
> that it always falls back to nobody, therefore giving me
> insufficient permissions.
> 
> The problem doesn't occur with rpc.idmapd (and disabled
> nfsidmap).
This is very odd...

> 
> My question would be whether there is an easy way to debug this?
> I tried to have a look at the kernel nfs4 client code / the
> interaction with idmap, but I just don't know enough about that
> area of the kernel to really see through the logic.

set the Verbosity = 9 in /etc/idmapd.conf the look
in /var/log/messages for the output...

steved.
