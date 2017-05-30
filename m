Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34721 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751510AbdE3JPL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 05:15:11 -0400
Received: by mail-io0-f180.google.com with SMTP id k91so52849254ioi.1
        for <linux-nfs@vger.kernel.org>; Tue, 30 May 2017 02:15:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87inkig1vw.fsf@notabene.neil.brown.name>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name> <CAGWsdOh5Sy-=8uv1aLUsCs+Co_QHgrkbUOJ0fXkb=Xskcez6JQ@mail.gmail.com>
 <87inkig1vw.fsf@notabene.neil.brown.name>
From: Michael Biebl <mbiebl@gmail.com>
Date: Tue, 30 May 2017 11:15:10 +0200
Message-ID: <CAGWsdOjd+HDity=qO0Rfk9RZ6bujwcXkR3MeZdN7ubroBPJ0sA@mail.gmail.com>
Subject: Re: [systemd-devel] [PATCH] nfs.man: document incompatibility between
 "bg" option and systemd.
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        systemd-devel@freedesktop.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2017-05-30 10:55 GMT+02:00 NeilBrown <neilb@suse.com>:
> On Tue, May 30 2017, Michael Biebl wrote:
>
>> 2017-05-30 0:19 GMT+02:00 NeilBrown <neilb@suse.com>:
>>
>>> +.B bg
>>> +option is not supported, and may be stripped from the option list.
>>
>> Either systemd is updated to actually strip the bg option or not. The
>> documentation should reflect that.
>> I don't think we should be vague about this, as it would only be confusing.
>
> It depends on which version of systemd is in use.
> Even if/when systemd is updated to strip the 'bg', it would not
> be correct to say "and will be stripped..." as that isn't true for all
> versions.
> We could spell it out "and may be stripped from the option list,
> depending on which version of systemd is installed", but I'm not sure
> that really helps...
>  "... and some versions of systemd will strip 'bg' from the option list"
>  ??

So far, no version of systemd strips bg from the option list.
If in version X systemd actually starts stripping bg, we should
explicitly mention that version in the man page imho.




-- 
Why is it that all of the instruments seeking intelligent life in the
universe are pointed away from Earth?
