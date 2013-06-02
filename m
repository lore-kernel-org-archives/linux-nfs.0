Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f182.google.com ([209.85.128.182]:39801 "EHLO
	mail-ve0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab3FBXFW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Jun 2013 19:05:22 -0400
MIME-Version: 1.0
In-Reply-To: <1370206557.46256.12.camel@leira.trondhjem.org>
References: <CAJ75kXa858MgWZ5A5dt+EswJyR4rJx1ke5Siv8hxds5FPJz_ww@mail.gmail.com>
 <1370206557.46256.12.camel@leira.trondhjem.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Mon, 3 Jun 2013 01:05:01 +0200
Message-ID: <CAJ75kXaxWV4Dcydc8tjOYm4=R-soRrH+YhCoVKz_hgZnYcT-Ew@mail.gmail.com>
Subject: Re: nfsv4 mount with noexec
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 2, 2013 at 10:56 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> The mount level flags such as 'nosuid', 'nodev' and 'noexec' are
> supposed to be enforced by the VFS, and not by the NFS code. The check
> is supposedly done in fs/exec.c:open_exec() after the file has been
> opened by the filesystem.
>
> Does 'cat /proc/mounts' actually show the noexec option being applied to
> the mountpoint by the kernel?

arg I mixed the original mount point and a binded mount point.

Sorry for the noise,

--
William
