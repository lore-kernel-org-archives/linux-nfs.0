Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:58696 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932678Ab2LMOiF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 09:38:05 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so1998809iay.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 Dec 2012 06:38:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121213142336.GP10897@ics.muni.cz>
References: <20121213133554.GO10897@ics.muni.cz>
	<CADnza44SJ0JZN05OtMZcjsm+NwdMVPGTa2f2vG9TbpUJR_B4Zw@mail.gmail.com>
	<20121213142336.GP10897@ics.muni.cz>
Date: Thu, 13 Dec 2012 09:38:04 -0500
Message-ID: <CADnza44SGwAJTJ8sFnAOoLHRPp1Mt9pJKk-scWmrigxD2G=zpQ@mail.gmail.com>
Subject: Re: local_lock mount option
From: Fred Isaman <faisaman4@gmail.com>
To: Lukas Hejtmanek <xhejtman@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 13, 2012 at 9:23 AM, Lukas Hejtmanek <xhejtman@gmail.com> wrote:
> On Thu, Dec 13, 2012 at 09:10:14AM -0500, Fred Isaman wrote:
>> local_lock is a v2/v3 option.  It does not currently effect the behavior of v4.
>
> if I understand correctly source codes, it should:
> nfs/file.c:
>
> const struct file_operations nfs4_file_operations = {
> [...]
>         .lock           = nfs_lock,
>         .flock          = nfs_flock,
>
> and nfs_(f)lock contains tests for:
> NFS_MOUNT_LOCAL_FCNTL
> NFS_MOUNT_LOCAL_FLOCK
>
> but for some reason, it is not propageted from mount call. Dunno why. Or am
> I something missing?
>
> --
> Lukáš Hejtmánek

It is turned off here:

static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
{
	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
			 NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
}

Fred
