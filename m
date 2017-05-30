Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35280 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750994AbdE3HkI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 03:40:08 -0400
Received: by mail-io0-f174.google.com with SMTP id f102so51526008ioi.2
        for <linux-nfs@vger.kernel.org>; Tue, 30 May 2017 00:40:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87tw43fgrf.fsf@notabene.neil.brown.name>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
From: Michael Biebl <mbiebl@gmail.com>
Date: Tue, 30 May 2017 09:40:07 +0200
Message-ID: <CAGWsdOh5Sy-=8uv1aLUsCs+Co_QHgrkbUOJ0fXkb=Xskcez6JQ@mail.gmail.com>
Subject: Re: [systemd-devel] [PATCH] nfs.man: document incompatibility between
 "bg" option and systemd.
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        systemd-devel@freedesktop.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2017-05-30 0:19 GMT+02:00 NeilBrown <neilb@suse.com>:

> +.B bg
> +option is not supported, and may be stripped from the option list.

Either systemd is updated to actually strip the bg option or not. The
documentation should reflect that.
I don't think we should be vague about this, as it would only be confusing.

Michael

-- 
Why is it that all of the instruments seeking intelligent life in the
universe are pointed away from Earth?
