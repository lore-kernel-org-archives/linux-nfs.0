Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tirith.ics.muni.cz ([147.251.4.36]:41001 "EHLO
	tirith.ics.muni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932346Ab2LMOuE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 09:50:04 -0500
Date: Thu, 13 Dec 2012 15:23:36 +0100
From: Lukas Hejtmanek <xhejtman@gmail.com>
To: Fred Isaman <faisaman4@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: local_lock mount option
Message-ID: <20121213142336.GP10897@ics.muni.cz>
References: <20121213133554.GO10897@ics.muni.cz>
 <CADnza44SJ0JZN05OtMZcjsm+NwdMVPGTa2f2vG9TbpUJR_B4Zw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <CADnza44SJ0JZN05OtMZcjsm+NwdMVPGTa2f2vG9TbpUJR_B4Zw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 13, 2012 at 09:10:14AM -0500, Fred Isaman wrote:
> local_lock is a v2/v3 option.  It does not currently effect the behavior of v4.

if I understand correctly source codes, it should:
nfs/file.c:

const struct file_operations nfs4_file_operations = {
[...]
        .lock           = nfs_lock,
        .flock          = nfs_flock,

and nfs_(f)lock contains tests for:
NFS_MOUNT_LOCAL_FCNTL
NFS_MOUNT_LOCAL_FLOCK

but for some reason, it is not propageted from mount call. Dunno why. Or am
I something missing?

-- 
Luká¹ Hejtmánek
