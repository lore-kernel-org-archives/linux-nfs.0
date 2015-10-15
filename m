Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:36048 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbbJOJRp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2015 05:17:45 -0400
Received: by qgx61 with SMTP id 61so65502603qgx.3
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2015 02:17:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1443061149-25153-1-git-send-email-roy.qing.li@gmail.com>
References: <1443061149-25153-1-git-send-email-roy.qing.li@gmail.com>
Date: Thu, 15 Oct 2015 17:17:44 +0800
Message-ID: <CAJFZqHzB=h9TWWj1rYRQe3Z_4fk6=7C75dViO6sM5MooB=k8Vw@mail.gmail.com>
Subject: Re: [PATCH] nfsroot: make nfsroot to accept the 1024 bytes long
 directory name
From: Li RongQing <roy.qing.li@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 24, 2015 at 10:19 AM,  <roy.qing.li@gmail.com> wrote:
> although NFS_MAXPATHLEN is defined to 1024, nfs client hopes to accept
> a 1024 byte path, but nfs_root_parms is limited to 256, and the nfs path
> will truncated when a user inputs nfs path from kernel cmdline
>
> enlarge nfs_root_parms to 1024, to make it accept the 1024 bytes long
> directory name, since nfs_root_parms is defined as _initdata, it will
> be released after system bootup




ping

-R
