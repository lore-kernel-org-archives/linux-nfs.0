Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:64671 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755668Ab2EGJHu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 05:07:50 -0400
MIME-Version: 1.0
In-Reply-To: <20120507085419.GN16608@gmail.com>
References: <1336230395-5215-1-git-send-email-levinsasha928@gmail.com> <20120507085419.GN16608@gmail.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 7 May 2012 11:00:52 +0200
Message-ID: <CA+1xoqc+4Bjgmnjx5kzMGr1ShVs8mbNppjr3OMa__tcFEcGuAA@mail.gmail.com>
Subject: Re: [PATCH] init: don't try mounting device as nfs root unless type
 fully matches
To: Ingo Molnar <mingo@kernel.org>
Cc: torvalds@linux-foundation.org, chuck.lever@oracle.com, linux@razik.name,
        Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mingo@elte.hu
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 7, 2012 at 10:54 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Sasha Levin <levinsasha928@gmail.com> wrote:
>
>> Currently, we'll try mounting any device who's major device number is
>> UNNAMED_MAJOR as NFS root. This would happen for non-NFS devices as well (such
>> as 9p devices) but it wouldn't cause any issues since mounting the device
>> as NFS would fail quickly and the code proceeded to doing the proper mount:
>>
>>        [  101.522716] VFS: Unable to mount root fs via NFS, trying floppy.
>>        [  101.534499] VFS: Mounted root (9p filesystem) on device 0:18.
>>
>> Commit 6829a048 ("NFS: Retry mounting NFSROOT") has introduced retries when
>> mounting NFS root, which means that now we don't immediately fail and instead
>> it takes an additional 90+ seconds until we stop retrying, which has revealed
>> the issue this patch fixes.
>
> Just wondering, which tree is commit 6829a048 included in? It
> does not appear to be mainline AFAICS.

It's 43717c7daebf10b43f12e68512484b3095bb1ba5 in mainline now.

Commit 6829a048 was from the -next tree (not sure which one of the
-next trees, but if you grab -next you'll see it there). I've prepared
this patch a while ago when it wasn't in mainline yet.
