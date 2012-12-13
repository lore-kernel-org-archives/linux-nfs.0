Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:54822 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932274Ab2LMOs0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 09:48:26 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so3984602ieb.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 Dec 2012 06:48:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121213144025.GA1045@ics.muni.cz>
References: <20121213133554.GO10897@ics.muni.cz>
	<CADnza44SJ0JZN05OtMZcjsm+NwdMVPGTa2f2vG9TbpUJR_B4Zw@mail.gmail.com>
	<20121213142336.GP10897@ics.muni.cz>
	<CADnza44SGwAJTJ8sFnAOoLHRPp1Mt9pJKk-scWmrigxD2G=zpQ@mail.gmail.com>
	<20121213144025.GA1045@ics.muni.cz>
Date: Thu, 13 Dec 2012 09:48:25 -0500
Message-ID: <CADnza45K-LgvNDt1_AoybesMobwsnw=vGX9D4wkvwKLKMkes5A@mail.gmail.com>
Subject: Re: local_lock mount option
From: Fred Isaman <faisaman4@gmail.com>
To: Lukas Hejtmanek <xhejtman@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 13, 2012 at 9:40 AM, Lukas Hejtmanek <xhejtman@gmail.com> wrote:
> On Thu, Dec 13, 2012 at 09:38:04AM -0500, Fred Isaman wrote:
>> It is turned off here:
>>
>> static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
>> {
>>       args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
>>                        NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
>> }
>
> ok, thanks. Is there any reason for this? I need to turn of locks for NFSv4 as
> they seem to not work properly with NFS server on CXFS.
>
> --
> Lukáš Hejtmánek

The idea is that delegations are a better way to decide whether the
client should cache locks.

Fred
