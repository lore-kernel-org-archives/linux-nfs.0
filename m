Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:53343 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933186Ab2KFB1t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 20:27:49 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so9023843iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 17:27:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1351760297.5369.1.camel@localhost>
References: <1351760297.5369.1.camel@localhost>
Date: Tue, 6 Nov 2012 09:27:49 +0800
Message-ID: <CA+res+RTz9DC8TK3N3kFrSpeT-rgad1nk7amJdWP_Up9OW9KSg@mail.gmail.com>
Subject: Re: hang problem when umount a nfs point
From: Jack Wang <jack.wang.usish@gmail.com>
To: dahai_tian@usish.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

Anyone who can kindly give some suggestion? or we just put question to
the wrong list?

Thanks.

Jack

2012/11/1 dahai_tian <dahai_tian@usish.com>:
> Hi all:
>         I mount a local directory to a nfs server. When nfs server is
> stopped
> for some accidental cause, I try to umount the mount point, the umount
> command will hang and 'time out' messages are continually printed in the
> terminal. How can I avoid hanging in this case? BTW, This issue does not
> exist when I changed nfs version from 4 to 3.
>         Look forward to your response, thanks!
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
