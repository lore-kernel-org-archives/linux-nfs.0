Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f41.google.com ([209.85.160.41]:58009 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbaAUNTI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jan 2014 08:19:08 -0500
MIME-Version: 1.0
In-Reply-To: <20140120133424.09328108@alan.etchedpixels.co.uk>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
	<1389953232-9428-2-git-send-email-piastry@etersoft.ru>
	<20140117181847.6c1f3831@alan.etchedpixels.co.uk>
	<CAKywueT=JsTkNC+w-vrN0ftam7F8Eqb8DXJ0w2G4q9vnt0hVNQ@mail.gmail.com>
	<20140120133424.09328108@alan.etchedpixels.co.uk>
Date: Tue, 21 Jan 2014 17:19:06 +0400
Message-ID: <CAKywueQhJE5F2t36OyrWBxKvXWagUbs47pUnBRbzRnX2025MKw@mail.gmail.com>
Subject: Re: [PATCH v7 1/7] VFS: Introduce new O_DENY* open flags
From: Pavel Shilovsky <piastry@etersoft.ru>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014/1/20 One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>:
>> > Shouldn't this also check for CAP_SYS_DAC or some similar permission so
>> > that root can override such a mess (eg to fix full disks in an
>> > emergency) ?
>>
>> May be it's better to let root an ability to remount the system
>> without sharelock mount option and then fix an emergency?
>
> Doesn't that involve breaking the service for all users of the system
> relying upon those locks, while root being allowed to ignore the locks
> does not ?

If we allow root to remount without "sharelock" (or bypass conflict
checks), it will definitely break the service for all users. Probably
it's better to stop the service (that cause all sharelocks to be
unlocked), fix the emergency and start the service again.

In the current state, the patchset doesn't allow any sort of ignoring
those locks for mounts with "sharelock" option (either remount without
"sharelock" or set special capabilities). It was done to make sure
nothing breaks applications relying upon sharelock behavior. Also,
that's why "sharelock" mount option was added: this behavior is
dangerous to be on critical system paths like "/" or "/lib" and not
suitable for global use.

-- 
Best regards,
Pavel Shilovsky.
