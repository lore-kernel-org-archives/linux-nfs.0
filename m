From: Pavel Shilovsky <piastry@etersoft.ru>
Subject: Re: [PATCH] mountd: Fix missing varialble assigment in auth_unix_gid
Date: Wed, 1 Jun 2011 22:55:27 +0400
Message-ID: <BANLkTikVKNLQNSPeUjLz-EEJ+zwtWz6zOg@mail.gmail.com>
References: <1306954194-2392-1-git-send-email-piastry@etersoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:61057 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632Ab1FASz1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 14:55:27 -0400
Received: by ywe9 with SMTP id 9so48559ywe.19
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jun 2011 11:55:27 -0700 (PDT)
In-Reply-To: <1306954194-2392-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2011/6/1 Pavel Shilovsky <piastry@etersoft.ru>:
> When we get into auth_unix_gid at the second time, groups_len
> is not 0 and ngroups variable leave as 0. Then we use ngroups
> in getgrouplist that fails in this case. This patch fixes it.
>
> Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>

Sorry for the spam - wrong title!

-- 
Best regards,
Pavel Shilovsky.
