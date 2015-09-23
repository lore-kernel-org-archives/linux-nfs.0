Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:34808 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755048AbbIWNdy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 09:33:54 -0400
Received: by lahg1 with SMTP id g1so50720587lah.1
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 06:33:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150922190224.GA19127@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-26-git-send-email-agruenba@redhat.com>
	<20150922190224.GA19127@fieldses.org>
Date: Wed, 23 Sep 2015 15:33:49 +0200
Message-ID: <CAHc6FU7_+fbyG0mEu3pUkfaV72AM0DzJnBES=b--koXJgo0a2g@mail.gmail.com>
Subject: Re: [RFC v7 25/41] richacl: Isolate the owner and group classes
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruen@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-22 21:02 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Sat, Sep 05, 2015 at 12:27:20PM +0200, Andreas Gruenbacher wrote:
>> +      * Compute the permissions already denied to @who.
>
> I'm not sure, but may be worth commenting on the lack of everyone denies
> here as you do in a couple places below.

Okay.

> As in the owner case, I think a goto would simplify the logic a little.

Yep, I'll clean that up.

>> +             /*
>> +              * Start from the entry before the trailing everyone@ allow
>> +              * entry.  We will not hit everyone@ entries in the loop.
>
> May as well skip the check below, in that case?

Indeed. You can almost tell from those few leftovers how the code has
evolved over time :)

Thanks,
Andreas
