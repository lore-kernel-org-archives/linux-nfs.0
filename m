Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23169 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753091Ab2F3LBI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Jun 2012 07:01:08 -0400
Date: Sat, 30 Jun 2012 07:00:36 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Andy Adamson <androsadamson@gmail.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/1] SUNRPC handle EKEYEXPIRED in call_refreshresult
Message-ID: <20120630070036.232946cb@tlielax.poochiereds.net>
In-Reply-To: <4FEE1381.1000209@RedHat.com>
References: <1340827535-3062-1-git-send-email-andros@netapp.com>
	<20120628114353.4f75aabc@tlielax.poochiereds.net>
	<19150370-D1BD-4CC1-90BD-383805DE9557@netapp.com>
	<20120628140351.527c5060@tlielax.poochiereds.net>
	<CAHVgHyWs+_Ep_wP6QASSJ18tM8OhYkQ+o=h5NKnOqdC6HWchKQ@mail.gmail.com>
	<4FEE1381.1000209@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 29 Jun 2012 16:43:45 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> >>>
> >>
> >> Easy to say, far more difficult to do.
> > 
> > Here is how simple it is.
> > 
> > $ kinit
> > $ krenew  -K 30&
> If this simple process cannot renew a ticket then its a bug
> in the client... We have to let processes like this to renew
> renewable tickets! 
> 
> I've never been a fan of this hang from the beginning but 
> if its getting in the way of things renewing tickets then its
> got to go... IMHO...
> 
> Lets push the error up to the app and then educate people
> on how to avoid the error... 
> 

Fair enough. I'd prefer to see this handled better too. If Andy has a
solution for the writeback issues then I'm fine with reverting this
behavior.

If we have kerberized NFS howtos anywhere (do we?) then we probably
need to add some notes about krenewd or how to make sssd handle this.

-- 
Jeff Layton <jlayton@redhat.com>
