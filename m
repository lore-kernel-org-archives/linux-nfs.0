Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:62952 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754735Ab1GVPCD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 11:02:03 -0400
In-Reply-To: <87livqfnin.fsf@tucsk.pomaz.szeredi.hu>
References: <1311323606-15040-1-git-send-email-avati@gluster.com>
	<1311323606-15040-2-git-send-email-avati@gluster.com>
	<87livqfnin.fsf@tucsk.pomaz.szeredi.hu>
Date: Fri, 22 Jul 2011 17:02:02 +0200
Message-ID: <CANXojcxyjBBPRYTxkiBGNzTFnirWnfH5_ZGMiahgMzNKkaL8gg@mail.gmail.com>
Subject: Re: [PATCH 2/2] fuse: permit O_DIRECT flag in open()
From: Stef Bon <stefbon@gmail.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Anand Avati <avati@gluster.com>, fuse-devel@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I do not like it. Setting O_DIRECT to the flags is an option which
should be set in the filesystem, not in the general library.

I'm working on a overlay fs with various backends, like a normal (part
of) partition on a ATA harddisk, a USB stick, a Cdrom, a mounted SMB
share.... and it is able to set the O_DIRECT flag, but always per
backend.

Stef

2011/7/22 Miklos Szeredi <miklos@szeredi.hu>:
> Anand Avati <avati@gluster.com> writes:
>
>> but do not permit setting of O_DIRECT flag via fcntl() (or unsetting)
>
> Again, some more verbose description would be good, as well as a
