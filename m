Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32792 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbbL2DRQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Dec 2015 22:17:16 -0500
Received: by mail-pa0-f51.google.com with SMTP id cy9so118059132pac.0
        for <linux-nfs@vger.kernel.org>; Mon, 28 Dec 2015 19:17:16 -0800 (PST)
Received: from [10.1.5.97] ([164.100.31.82])
        by smtp.googlemail.com with ESMTPSA id tv6sm29903018pab.4.2015.12.28.19.17.14
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Mon, 28 Dec 2015 19:17:15 -0800 (PST)
Subject: Re: How do you get /proc/fs/nfs/exports to populate?
References: <567E812E.2040204@gmail.com> <568103AF.2010500@gmail.com>
 <20151228102116.4f687c6e@tlielax.poochiereds.net>
To: linux-nfs@vger.kernel.org
From: dE <de.techno@gmail.com>
Message-ID: <5681FB44.3020704@gmail.com>
Date: Tue, 29 Dec 2015 08:47:24 +0530
MIME-Version: 1.0
In-Reply-To: <20151228102116.4f687c6e@tlielax.poochiereds.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for clearing that up. Explains the erratic behavior without mountd.

On 12/28/15 20:51, Jeff Layton wrote:
> On Mon, 28 Dec 2015 15:11:03 +0530
> dE <de.techno@gmail.com> wrote:
>
>> Ok, got it.
>>
>> It happens that those are made after a mount request.
>>
> Well, there is no such thing as a mount request, per-se in NFSv4. What
> happens is that you try to walk down to the point where you're mounting
> and access that inode, and nfsd upcalls to mountd to see whether that's
> allowed. That populates the cache.
>
> You can't really run nfsd without mountd (or something equivalent)
> since something needs to populate the exports table. If you're running
> a v4-only server though, then mountd doesn't need to be network-facing
> however.
>
>> On 12/26/15 17:29, dE wrote:
>>> Hi!
>>>      I'm running nfs-utils without init script or systemd unit assistance.
>>>
>>> Since I'm using nfsv4, I'm eliminating the need to start mountd.
>>>
>>> Now if mountd is gone, who populates /proc/fs/nfs/exports?
>>>
>>> But even after running mountd (after an exportfs -a), this file still
>>> does not have any entries.
>>>
>>> Running rpc.nfsd with --
>>>
>>> rpc.nfsd -d --syslog --port 10000
>>>
>>> rpc.mountd runs without any arguments.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

