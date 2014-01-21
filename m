Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.SerNet.de ([193.175.80.2]:59283 "EHLO mail.SerNet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754472AbaAUORV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jan 2014 09:17:21 -0500
Date: Tue, 21 Jan 2014 15:17:08 +0100
Date: Tue, 21 Jan 2014 15:17:08 +0100
From: Volker Lendecke <Volker.Lendecke@SerNet.DE>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org
Subject: Re: [PATCH v7 0/7] Add O_DENY* support for VFS and CIFS/NFS
Reply-To: Volker.Lendecke@SerNet.DE
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
 <E1W5A0e-000MT9-A1@intern.SerNet.DE>
 <CAKywueQwfFASPpevO8Z-_xwZqRjkzfkOceQJDya8D7FDW+UmMg@mail.gmail.com>
 <E1W5C8U-000ozD-Ku@intern.SerNet.DE>
 <CAKywueQng9=u1YYwkYGCunWW8RBhARhJjEhBcoA6CKF6TrKSBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <CAKywueQng9=u1YYwkYGCunWW8RBhARhJjEhBcoA6CKF6TrKSBg@mail.gmail.com>
Message-Id: <E1W5c8k-0036ba-7A@intern.SerNet.DE>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 21, 2014 at 05:31:39PM +0400, Pavel Shilovsky wrote:
> It's not possible with the current API to do it through open syscall.
> Another possibility is to look at /proc/locks. But I think we really
> need O_DELETE flag that will force a file to be removed on close - we
> will be able to do O_DENYDELETE checks atomically.

I don't depend on this at open time. I can do it later with
some syscall, that's fine. I just want to find a way to do
it correctly. The problem is -- you can't "try" an unlink.
So we have to probe whether we can unlink. And opening for
O_DENYDELETE by no means says we *will* unlink. We just have
to keep the option to do it exclusively.

With best regards,

Volker

-- 
SerNet GmbH, Bahnhofsallee 1b, 37081 Göttingen
phone: +49-551-370000-0, fax: +49-551-370000-9
AG Göttingen, HRB 2816, GF: Dr. Johannes Loxen
http://www.sernet.de, mailto:kontakt@sernet.de
