Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f42.google.com ([74.125.82.42]:57283 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975Ab3HUFgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Aug 2013 01:36:00 -0400
Received: by mail-wg0-f42.google.com with SMTP id j13so233557wgh.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Aug 2013 22:35:59 -0700 (PDT)
Message-ID: <521451BD.3050601@primarydata.com>
Date: Wed, 21 Aug 2013 08:35:57 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Joe Lee <joe.lee@musician.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: MDS setup
References: <5202C154.6020907@musician.org> <loom.20130813T090508-522@post.gmane.org>
In-Reply-To: <loom.20130813T090508-522@post.gmane.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-08-13 10:23, Joe Lee wrote:
> It was a ridiculously stupid oversight: I hadn't built the pnfs support in
> the kernel.

:)

> 
> I got things squared away by running "make menuconfig" and enabling "NFSv4.1
> server support for Parallel NFS (pNFS) (DEVELOPER ONLY)" under
> 
> File systems --->
> 
>   Network File Systems --->
> 
>     NFS server support
> 
>       NFS server support for NFS version 4 (EXPERIMENTAL)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
