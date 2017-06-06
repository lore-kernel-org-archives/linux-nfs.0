Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:35232 "EHLO
        mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751247AbdFFT5d (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jun 2017 15:57:33 -0400
Received: by mail-yw0-f173.google.com with SMTP id 141so8259887ywe.2
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jun 2017 12:57:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name> <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
From: Michael Biebl <mbiebl@gmail.com>
Date: Tue, 6 Jun 2017 21:57:32 +0200
Message-ID: <CAGWsdOjswhfUszn0AmFtFcz-sbDU8=qFr5z1=tNigROOPBS0Rw@mail.gmail.com>
Subject: Re: [systemd-devel] [PATCH] nfs.man: document incompatibility between
 "bg" option and systemd.
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org,
        systemd-devel@freedesktop.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2017-06-06 20:07 GMT+02:00 Steve Dickson <SteveD@redhat.com>:
> Finally, the whole idea of systemd randomly/silently
> strip off mount options is crazy... IMHO...

Personally, I would prefer if systemd simply logged a warning/error
message but would *not* strip the bg option.


-- 
Why is it that all of the instruments seeking intelligent life in the
universe are pointed away from Earth?
