Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34641 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbcFNW5J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 18:57:09 -0400
Received: by mail-yw0-f194.google.com with SMTP id b75so602940ywe.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 15:57:08 -0700 (PDT)
Message-ID: <1465945026.12291.5.camel@poochiereds.net>
Subject: Re: [PATCH v2] nfsd: Always lock state exclusively.
From: Jeff Layton <jlayton@poochiereds.net>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "J . Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Tue, 14 Jun 2016 18:57:06 -0400
In-Reply-To: <F7BC1638-0C44-4ED5-8483-EEF9A673EA4B@linuxhacker.ru>
References: <30E98D26-CB99-4BF8-8697-A2E9BB41920D@linuxhacker.ru>
	 <1465781187-824653-1-git-send-email-green@linuxhacker.ru>
	 <20160614153808.GD25973@fieldses.org>
	 <ED916555-2D4D-4BF5-8850-9A17D0ABFE82@linuxhacker.ru>
	 <20160614185032.GJ25973@fieldses.org>
	 <1465944743.12291.4.camel@poochiereds.net>
	 <F7BC1638-0C44-4ED5-8483-EEF9A673EA4B@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-06-14 at 18:54 -0400, Oleg Drokin wrote:
> On Jun 14, 2016, at 6:52 PM, Jeff Layton wrote:
> > 
> > I think I'd still prefer to have it unlock the mutex in the event that
> > it's not going to use it after all. While that kind of thing is ok for
> > now, it's stuff like that that can turn into a subtle source of bugs
> > later.
> > 
> > Also, I think I'd be more comfortable with this being split into (at
> > least) two patches. Do one patch as a straight conversion from rwsem to
> > mutex, and then another that changes the code to take the mutex before
> > hashing the new stateid.
> Ok, I guess that could be arranged too.
> 
> And then there's this Bruce's patch to pull more stuff into the init_open_stateid

Yeah, that seems like a good idea. We _really_ need an effort to
simplify this code. OPEN handling is always messy, but the current code
is really much messier than it should be.

-- 
Jeff Layton <jlayton@poochiereds.net>
