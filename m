Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tirith.ics.muni.cz ([147.251.4.36]:55968 "EHLO
	tirith.ics.muni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932230Ab2LMOk3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 09:40:29 -0500
Date: Thu, 13 Dec 2012 15:40:25 +0100
From: Lukas Hejtmanek <xhejtman@gmail.com>
To: Fred Isaman <faisaman4@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: local_lock mount option
Message-ID: <20121213144025.GA1045@ics.muni.cz>
References: <20121213133554.GO10897@ics.muni.cz>
 <CADnza44SJ0JZN05OtMZcjsm+NwdMVPGTa2f2vG9TbpUJR_B4Zw@mail.gmail.com>
 <20121213142336.GP10897@ics.muni.cz>
 <CADnza44SGwAJTJ8sFnAOoLHRPp1Mt9pJKk-scWmrigxD2G=zpQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <CADnza44SGwAJTJ8sFnAOoLHRPp1Mt9pJKk-scWmrigxD2G=zpQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 13, 2012 at 09:38:04AM -0500, Fred Isaman wrote:
> It is turned off here:
> 
> static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
> {
> 	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
> 			 NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
> }

ok, thanks. Is there any reason for this? I need to turn of locks for NFSv4 as
they seem to not work properly with NFS server on CXFS.

-- 
Luká¹ Hejtmánek
