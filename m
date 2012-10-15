Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f46.google.com ([209.85.219.46]:47573 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304Ab2JOQCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Oct 2012 12:02:49 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so5121328oag.19
        for <linux-nfs@vger.kernel.org>; Mon, 15 Oct 2012 09:02:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90923ED96@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121015080539.23088.qmail@science.horizon.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90923ED96@SACEXCMBX04-PRD.hq.netapp.com>
Date: Mon, 15 Oct 2012 09:02:45 -0700
Message-ID: <CAA7C2qhn-Z8iAp_Cqg6s0DURCRSh=238kHnNMn=i8rXfFX1hAg@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
From: VDR User <user.vdr@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: George Spelvin <linux@horizon.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 15, 2012 at 5:19 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> I do mind; it is clearly starting to bitrot due to an absence of users.
> Maintenance of unused code is actually _more_ of a pain, not less.
>
> So unfsd is one solution. Keeping a VM with an older version of the
> Linux kernel that still supports NFSv2 is another. Volunteering to
> maintain the code is a third.

Growing pains can be hard for those who can't/won't update but when
it's time to move on, it's time to move on. Maintaining code _is_ in
fact a chore that eventually becomes counter-productive once the user
base has diminished enough and/or it's become so outdated. Your
suggestions might not thrill other people but then who likes taking
their medicine?

Cheers
