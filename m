Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.SerNet.de ([193.175.80.2]:53836 "EHLO mail.SerNet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752569AbaATIqJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 03:46:09 -0500
Date: Mon, 20 Jan 2014 09:14:54 +0100
Date: Mon, 20 Jan 2014 09:14:54 +0100
From: Volker Lendecke <Volker.Lendecke@SerNet.DE>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v7 0/7] Add O_DENY* support for VFS and CIFS/NFS
Reply-To: Volker.Lendecke@SerNet.DE
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
Message-Id: <E1W5A0e-000MT9-A1@intern.SerNet.DE>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

On Fri, Jan 17, 2014 at 02:07:05PM +0400, Pavel Shilovsky wrote:
> If O_DENYDELETE flag is specified and the open succeded,
> any further unlink operation will fail with -ESHAREDENIED
> untill this open is closed. Now this flag is processed by
> VFS and CIFS filesystem. NFS returns -EINVAL for opens
> with this flag.

This looks really, really good, thanks!

One question: If Samba wants to open a file for delete
access, there's no corresponding flag in the open
permissions. There can be the case where Samba wants to open
*just* for future unlink, no read or write access required.
Is there a way to achieve this atomically correct?

Thanks,

Volker

-- 
SerNet GmbH, Bahnhofsallee 1b, 37081 Göttingen
phone: +49-551-370000-0, fax: +49-551-370000-9
AG Göttingen, HRB 2816, GF: Dr. Johannes Loxen
http://www.sernet.de, mailto:kontakt@sernet.de
