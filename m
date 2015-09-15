Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34923 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbbIOL7i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2015 07:59:38 -0400
Received: by qgt47 with SMTP id 47so139754739qgt.2
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2015 04:59:37 -0700 (PDT)
Date: Tue, 15 Sep 2015 07:59:34 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Andrew W Elble <aweits@rit.edu>
Cc: Bruce James Fields <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: upgrade/downgrade race
Message-ID: <20150915075934.48c4f0fe@tlielax.poochiereds.net>
In-Reply-To: <m2eghzrjg2.fsf@discipline.rit.edu>
References: <m2h9n3btno.fsf@discipline.rit.edu>
	<CAHQdGtQ84tUFEXaUwSngAmQst3NbjZDCSwB2jtqRqR29R4wBWg@mail.gmail.com>
	<CAHQdGtTvPPXjSm8Aq6AefMec4UEUwL6+swwav8SSFMQJMDchCA@mail.gmail.com>
	<20150909144935.51e3653b@tlielax.poochiereds.net>
	<CAHQdGtS2BL+d9NvV5adG=Mts0Qx6_=5Fwo34+nbz-eMVepnnKg@mail.gmail.com>
	<20150909151801.3fd2243f@tlielax.poochiereds.net>
	<20150909204036.GD25750@fieldses.org>
	<20150909170037.77776b5a@tlielax.poochiereds.net>
	<20150909213907.GF25750@fieldses.org>
	<20150912081037.6658649c@tlielax.poochiereds.net>
	<m2eghzrjg2.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 15 Sep 2015 07:49:33 -0400
Andrew W Elble <aweits@rit.edu> wrote:

> 
> > Andrew, could you test this patch out? This just covers open and lock
> > stateids. If it works, I'll clean up the comments and resend it to the
> > list as a PATCH email.
> >
> > Assuming that it does, we'll need to consider what (if anything) to do
> > about layout stateids...
> 
> Jeff,
> 
>    We've run with no issues overnight. I'll let you know if we see
>    anything weird in the next few days (It generally takes a few days at
>    this point to trigger anything out-of-the-ordinary)
> 
> 
> Thanks,
> 
> Andy
> 

Great. Thanks for helping test it!

-- 
Jeff Layton <jeff.layton@primarydata.com>
