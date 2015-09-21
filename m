Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:36591 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756543AbbIUXoX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 19:44:23 -0400
Received: by lbcao8 with SMTP id ao8so59441284lbc.3
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2015 16:44:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150918213611.GC22671@fieldses.org>
References: <1441448856-13478-1-git-send-email-agruenba@redhat.com>
	<1441448856-13478-23-git-send-email-agruenba@redhat.com>
	<20150918213611.GC22671@fieldses.org>
Date: Tue, 22 Sep 2015 01:44:21 +0200
Message-ID: <CAHc6FU5QD04bw53mX=pVGmnz2v-w6EhmLftc-OHm_Gnkm2_u-A@mail.gmail.com>
Subject: Re: [RFC v7 22/41] richacl: Propagate everyone@ permissions to other aces
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruen@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-09-18 23:36 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Sat, Sep 05, 2015 at 12:27:17PM +0200, Andreas Gruenbacher wrote:
>> +     if (!richace_is_owner(who) &&
>> +         richace_is_everyone(ace) && richace_is_allow(ace) &&
>
> That richace_is_allow(ace) check is redundant at this point, isn't it?

Yes, I'll change that.

>> +         !(allow & ~(ace->e_mask & acl->a_other_mask)))
>
> Uh, I wish C had a subset-of operator, that construct took me longer to
> work out than I should admit.
>
>> +             allow = 0;
>> +
>> +     if (allow) {
>> +             if (allow_last)
>> +                     return richace_change_mask(alloc, &allow_last,
>> +                                                allow_last->e_mask | allow);
>> +             else {
>> +                     struct richace who_copy;
>> +
>> +                     richace_copy(&who_copy, who);
>> +                     ace = acl->a_entries + acl->a_count - 1;
>
> Isn't ace already set to the last ace?

Yes indeed, that line can also go.

Thanks,
Andreas
