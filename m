Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f47.google.com ([209.85.160.47]:45797 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbaAUNbk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jan 2014 08:31:40 -0500
MIME-Version: 1.0
In-Reply-To: <E1W5C8U-000ozD-Ku@intern.SerNet.DE>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
	<E1W5A0e-000MT9-A1@intern.SerNet.DE>
	<CAKywueQwfFASPpevO8Z-_xwZqRjkzfkOceQJDya8D7FDW+UmMg@mail.gmail.com>
	<E1W5C8U-000ozD-Ku@intern.SerNet.DE>
Date: Tue, 21 Jan 2014 17:31:39 +0400
Message-ID: <CAKywueQng9=u1YYwkYGCunWW8RBhARhJjEhBcoA6CKF6TrKSBg@mail.gmail.com>
Subject: Re: [PATCH v7 0/7] Add O_DENY* support for VFS and CIFS/NFS
From: Pavel Shilovsky <piastry@etersoft.ru>
To: "Volker.Lendecke@SerNet.DE" <Volker.Lendecke@sernet.de>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014/1/20 Volker Lendecke <Volker.Lendecke@sernet.de>:
>> You can try to use O_PATH flag. It doesn't give you a delete access
>> but should be ok because further deleting will be done without file
>> descriptor -- through unlink syscall.
>
> Ok, I did not know about O_PATH. Thanks for that!
>
> So I do an open with O_PATH. How do I then make sure that
> nobody else has a O_DENYDELETE set without doing the unlink
> itself?

It's not possible with the current API to do it through open syscall.
Another possibility is to look at /proc/locks. But I think we really
need O_DELETE flag that will force a file to be removed on close - we
will be able to do O_DENYDELETE checks atomically.

-- 
Best regards,
Pavel Shilovsky.
