Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp3.ugent.be ([157.193.49.127]:47894 "EHLO smtp3.UGent.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757119Ab1GDQ2c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jul 2011 12:28:32 -0400
Message-ID: <4E11EA30.9070302@debian.org>
Date: Mon, 04 Jul 2011 18:28:32 +0200
From: Luk Claes <luk@debian.org>
To: Jim Rees <rees@umich.edu>
CC: NeilBrown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not segfault because of kernel version
References: <1309617149-3993-1-git-send-email-luk@debian.org> <20110703150421.2db09d94@notabene.brown> <4E100E17.5000304@debian.org> <20110703130237.GA9889@merit.edu> <4E106A56.1050802@debian.org> <20110703132605.GC9889@merit.edu> <4E106E91.8080208@debian.org> <20110703141134.GA10071@merit.edu>
In-Reply-To: <20110703141134.GA10071@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/03/2011 04:11 PM, Jim Rees wrote:
> Luk Claes wrote:
> 
>   > Yes, just return UINT_MAX.  Fix the other error return too, the one where
>   > uname fails.  And put in a comment if you can briefly summarize Linus's
>   > argument.
>   
>   I thought that a real error like uname failing should still get the
>   'wrong' return 0, no?
> 
> No.  As I read it, Linus argues that you should only run the backward
> compatibility code path when you know you're running an older kernel.  If
> you don't know, then you should assume you're running a newer kernel.

So, if uname fails we treat it as a newer kernel, shouldn't we treat
that as an error? So treating it as a special case instead of running
backward compatibility or as a newer kernel?

Cheers

Luk
