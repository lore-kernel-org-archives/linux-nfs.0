Return-Path: linux-nfs-owner@vger.kernel.org
Received: from arafel.iwakd.de ([78.46.72.57]:56180 "EHLO arafel.iwakd.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750913AbaHMRv2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2014 13:51:28 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 13 Aug 2014 19:45:16 +0200
From: Christian Seiler <christian@iwakd.de>
To: Steve Dickson <steved@redhat.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] libnfsidmap: respect Nobody-User/Nobody-Group
In-Reply-To: <53EB962C.5000001@RedHat.com>
References: <1401794264-3975-1-git-send-email-christian@iwakd.de>
 <53EB962C.5000001@RedHat.com>
Message-ID: <603dd17035c81999c99b9020b65d8768@iwakd.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Am 2014-08-13 18:45, schrieb Steve Dickson:
> On 06/03/2014 07:17 AM, Christian Seiler wrote:
>> Previous behavior of libnfsidmap was to do a name lookup of
>> nobody@DEFAULTDOMAIN (for both user and group), which does not match
>> the behavior of rpc.idmapd.
>>
>> This patch makes libnfsidmap respect Nobody-User/Nobody-Group for
>> lookups, thus making the nfsidmap utility properly handle the case 
>> if
>> nobody@DEFAULTDOMAIN does not directly map to any user/group on the
>> system.
>>
>> Signed-off-by: Christian Seiler <christian@iwakd.de>
> Wow... This one fell of the radar... sorry about that!

No problem. To be honest, I completely forgot about this patch
myself, because I wrote this patch when I tried to switch from
idmapd to nfsidmap, but after I had some problems with that, I
kind of switched back to idmapd, and then kind of put the whole
thing to the back of my mind.

But perhaps you can give me a couple of pointers on how to
best debug the issue I had with nfsidmap:

  - nsswitch translation for idmapping, nss_ldapd
  - nfsv4 sec=krb5 mount (mounted via autofs)
  - no krb5 ticket: ls doesn't even work (permission denied)
    (this is expected, not a bug)
  - with krb5 ticket: ls -l shows correct directory contents,
    with correct user/group ownership (translation nfs4 ->
    uid/gid via nfsidmap and then uid/gid -> local names via
    getpwnam works)
  - accessing files owned by myself but that are not group/other
    readable doesn't work (permission denied)
  - writing to files / directories on which I have write
    permission (but no other write permission) doesn't work
  - nfsv4 sec=sys mounts don't have this problem

To me this appears to be a problem that while uids/gids are
correctly mapped when getting data from the server, they are
not mapped properly when sending requests to the server, so
that it always falls back to nobody, therefore giving me
insufficient permissions.

The problem doesn't occur with rpc.idmapd (and disabled
nfsidmap).

My question would be whether there is an easy way to debug this?
I tried to have a look at the kernel nfs4 client code / the
interaction with idmap, but I just don't know enough about that
area of the kernel to really see through the logic.

> Committed!

Thanks!

Regards,
Christian

