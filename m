Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.SerNet.de ([193.175.80.2]:50548 "EHLO mail.SerNet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732AbaATKbc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 05:31:32 -0500
Date: Mon, 20 Jan 2014 11:31:13 +0100
Date: Mon, 20 Jan 2014 11:31:13 +0100
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
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <CAKywueQwfFASPpevO8Z-_xwZqRjkzfkOceQJDya8D7FDW+UmMg@mail.gmail.com>
Message-Id: <E1W5C8U-000ozD-Ku@intern.SerNet.DE>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 20, 2014 at 02:20:43PM +0400, Pavel Shilovsky wrote:
> > One question: If Samba wants to open a file for delete
> > access, there's no corresponding flag in the open
> > permissions. There can be the case where Samba wants to open
> > *just* for future unlink, no read or write access required.
> > Is there a way to achieve this atomically correct?
> 
> You can try to use O_PATH flag. It doesn't give you a delete access
> but should be ok because further deleting will be done without file
> descriptor -- through unlink syscall.

Ok, I did not know about O_PATH. Thanks for that!

So I do an open with O_PATH. How do I then make sure that
nobody else has a O_DENYDELETE set without doing the unlink
itself?

Thanks,

Volker

-- 
SerNet GmbH, Bahnhofsallee 1b, 37081 Göttingen
phone: +49-551-370000-0, fax: +49-551-370000-9
AG Göttingen, HRB 2816, GF: Dr. Johannes Loxen
http://www.sernet.de, mailto:kontakt@sernet.de
