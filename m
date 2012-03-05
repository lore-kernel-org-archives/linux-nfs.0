Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751563Ab2CEToA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 14:44:00 -0500
Message-ID: <4F551781.8030803@RedHat.com>
Date: Mon, 05 Mar 2012 14:44:01 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/1] Normalized path names on umounts (take 2)
References: <1330976165-19849-1-git-send-email-steved@redhat.com> <5C0B4422-2BF3-4534-817C-0480B1A21D34@oracle.com>
In-Reply-To: <5C0B4422-2BF3-4534-817C-0480B1A21D34@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/05/2012 02:37 PM, Chuck Lever wrote:
> 
> On Mar 5, 2012, at 2:36 PM, Steve Dickson wrote:
> 
>> There is a second attempted at making paths in the
>> device names that have multiple slashes or no slash
>> at all unmount-able, without breaking any APIs.
>>
>> Due to the way entries are written to both the /etc/mtab
>> and /proc/mounts, multiple slash have to be stripped and
>> leading slash have to be added (when they don't exist) 
>> on v4 mounts.
> 
> I thought a pathname without a leading slash was allowed for NFSv4, for mounting OSD devices?  Not really sure.
Sorry I guess I didn't make myself clear... this adding and subtracting 
of slashes only happen on umounts and only if /etc/mtab is not symbolically
to /proc/mounts.  Has no effect on the mounts that do or do not have 
slashes... Is that a bit clearer? 

steved.

> 
>> With v3 mounts this normalization can 
>> not occur since those entries are always in the same format.
>>
>> Finally, this normalization only needs to happen
>> when the mtab and /proc/mounts are not the same file.
>>
>> Steve Dickson (1):
>>  umount.nfs: normalize path names during umounts.
>>
>> utils/mount/nfsumount.c |   64 +++++++++++++++++++++++++++++++++++++++++++++-
>> 1 files changed, 62 insertions(+), 2 deletions(-)
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
