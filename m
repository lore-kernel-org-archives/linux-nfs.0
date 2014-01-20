Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:40821 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbaATJ42 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jan 2014 04:56:28 -0500
MIME-Version: 1.0
In-Reply-To: <051001cf13b4$080833b0$18189b10$@mindspring.com>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
	<051001cf13b4$080833b0$18189b10$@mindspring.com>
Date: Mon, 20 Jan 2014 13:56:26 +0400
Message-ID: <CAKywueTOi-WPpgH7x3VK7EkGJXE8fHUqcLgSUm6o6UA+uaQtjA@mail.gmail.com>
Subject: Re: [PATCH v7 0/7] Add O_DENY* support for VFS and CIFS/NFS
From: Pavel Shilovsky <piastry@etersoft.ru>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014/1/17 Frank Filz <ffilzlnx@mindspring.com>:
> This looks wonderful and will be useful to the Ganesha user space NFS server
> also.
>
> I do have a couple questions.
>
> 1. How will this interact with the idea of private locks from the patch set
> Jeff Layton has been pushing?

They don't touch each other.

>
> 2. If a process opens multiple file descriptors with deny modes, will they
> conflict with each other (which is the behavior we will want for Ganesha).

Yes, a deny mode is associated with file descriptor - so, it will
conflict with any other access/deny modes of file descriptors from any
process.

>
> 3. Is there any functionality to upgrade or downgrade the access and deny
> modes (thinking in terms of NFS v4 support of OPEN upgrade and
> OPEN_DOWNGRADE operations).

The proposed patchset doesn't allow to change deny modes after an open
is done. But we can add a functionality to let flock syscall change
deny modes as on option.

-- 
Best regards,
Pavel Shilovsky.
