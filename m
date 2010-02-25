From: Anton Starikov <ant.starikov@gmail.com>
Subject: Re: NFS bug with  2.6.18-164.11.1.el5 kernel
Date: Fri, 26 Feb 2010 00:26:16 +0100
Message-ID: <763279E0-7883-44F6-8EE8-B48BEA32FC44@gmail.com>
References: <0D307444-5CDB-42BB-B8CD-7C37165946B4@gmail.com> <20100225180604.42c7043a@tupile.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35788 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934488Ab0BYX0V convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Feb 2010 18:26:21 -0500
Received: by wya21 with SMTP id 21so2175097wya.19
        for <linux-nfs@vger.kernel.org>; Thu, 25 Feb 2010 15:26:20 -0800 (PST)
In-Reply-To: <20100225180604.42c7043a-PC62bkCOHzGdMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 26, 2010, at 12:06 AM, Jeff Layton wrote:
> I can't comment on any of the above since it doesn't contain any
> specific info other than "my stuff doesn't work".

Sorry, if it looks impolite. Just tired and nervous.

> Hmmm...so this "blcr" module is calling down into vfs_create (I guess
> to create a device or pipe or something?). If it's crashing in
> encode_share_access then I suspect that the problem is that it's not
> filling out the open_intent data in the nameidata that it's passing
> down to vfs_create.
> 
> IOW, this is likely a bug in the "blcr" module and not in RHEL.

With kernel from OpenSUSE 11.2 (2.6.31) it works. In exactly the same setup.
I'll check, it might be chance that there is an issue with earlier kernel. But it happens only with NFS, it works when everything is on block-storage.

I will also crosspost it to BLCR mail-list.

Anton