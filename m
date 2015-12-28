Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34611 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbbL1Jk5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Dec 2015 04:40:57 -0500
Received: by mail-pf0-f176.google.com with SMTP id e65so58256530pfe.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 Dec 2015 01:40:56 -0800 (PST)
Received: from [10.1.5.97] ([164.100.31.82])
        by smtp.googlemail.com with ESMTPSA id sg4sm80035068pac.48.2015.12.28.01.40.54
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Mon, 28 Dec 2015 01:40:55 -0800 (PST)
Subject: Re: How do you get /proc/fs/nfs/exports to populate?
To: linux-nfs@vger.kernel.org
References: <567E812E.2040204@gmail.com>
From: dE <de.techno@gmail.com>
Message-ID: <568103AF.2010500@gmail.com>
Date: Mon, 28 Dec 2015 15:11:03 +0530
MIME-Version: 1.0
In-Reply-To: <567E812E.2040204@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, got it.

It happens that those are made after a mount request.

On 12/26/15 17:29, dE wrote:
> Hi!
>     I'm running nfs-utils without init script or systemd unit assistance.
>
> Since I'm using nfsv4, I'm eliminating the need to start mountd.
>
> Now if mountd is gone, who populates /proc/fs/nfs/exports?
>
> But even after running mountd (after an exportfs -a), this file still 
> does not have any entries.
>
> Running rpc.nfsd with --
>
> rpc.nfsd -d --syslog --port 10000
>
> rpc.mountd runs without any arguments.

