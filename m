Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:46003 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764094Ab3DDRpV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2013 13:45:21 -0400
MIME-Version: 1.0
In-Reply-To: <20130404090232.30457b32@corrin.poochiereds.net>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
	<1362065133-9490-7-git-send-email-piastry@etersoft.ru>
	<20130311145434.707f5ed1@corrin.poochiereds.net>
	<20130312083517.770a17f6@tlielax.poochiereds.net>
	<CAKywueRSTipeO8V-oNrM=jM8WUo7Dd0ahj_Xcw8f8ViE3NGEOQ@mail.gmail.com>
	<20130404090232.30457b32@corrin.poochiereds.net>
Date: Thu, 4 Apr 2013 21:45:20 +0400
Message-ID: <CAKywueTcy8gMy=TVpj=TnfRMBj9e3xPCpaJvUmRd=TvT5uJHFw@mail.gmail.com>
Subject: Re: [PATCH v3 6/7] NFSv4: Add O_DENY* open flags support
From: Pavel Shilovsky <piastry@etersoft.ru>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-cifs <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/4/4 Jeff Layton <jlayton@redhat.com>:
> I'd probably still stick with a FS_* flag for this...
>
> That sort of mechanism would work (for now) but sounds like the sort of
> subtle behavior that's difficult for filesystem authors to get right.
> It would also be subject to subtle breakage later.
>
> Also, suppose there are changes in the future that require you to
> determine this before calling into ->open? Then you'll have to go back
> and somehow mark the fs anyway...

Ok, this makes sense, thanks. Will do it this way and repost.

--
Best regards,
Pavel Shilovsky.
