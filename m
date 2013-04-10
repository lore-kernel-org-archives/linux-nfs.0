Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f172.google.com ([209.85.210.172]:61743 "EHLO
	mail-ia0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936414Ab3DJN73 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2013 09:59:29 -0400
MIME-Version: 1.0
In-Reply-To: <20130410081221.753e4bb3@corrin.poochiereds.net>
References: <1365511227-17626-1-git-send-email-piastry@etersoft.ru>
	<1365511227-17626-5-git-send-email-piastry@etersoft.ru>
	<20130410071144.08ef2983@corrin.poochiereds.net>
	<CAKywueSPh2vXvS1HRmJHZUApo_YxWjcp4_2ZXgb1RHafS=A98w@mail.gmail.com>
	<20130410081221.753e4bb3@corrin.poochiereds.net>
Date: Wed, 10 Apr 2013 17:59:28 +0400
Message-ID: <CAKywueQ9quCRZJocxwsg=hzS1eEzM0jCB-RAQwzYa7dWeEEoUQ@mail.gmail.com>
Subject: Re: [PATCH v5 4/7] CIFS: Use NT_CREATE_ANDX command for forcemand mounts
From: Pavel Shilovsky <piastry@etersoft.ru>
To: Jeff Layton <jlayton@samba.org>
Cc: linux-cifs <linux-cifs@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/4/10 Jeff Layton <jlayton@samba.org>:
> (cc'ing samba-technical)
>
> I don't understand. Why would we need to use NT_CREATE_ANDX in lieu of
> the POSIX trans2 open if the client isn't setting a share reservation
> on that particular open? The server should still enforce share
> reservations that are already set on the file regardless of which
> method is used.

Ok, I checked it out: Samba still enforce share reservations for
trans2 opens too. In this case we need a check like

if (IS_SHARELOCK(inode) && cifs_get_share_flags(openflags) != FILE_SHARE_ALL)
        /* use NT_CREATE_ANDX */
else
       /* use TRANS2 OPEN */

--
Best regards,
Pavel Shilovsky.
