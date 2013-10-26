Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33663 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753150Ab3JZTW1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Oct 2013 15:22:27 -0400
Date: Sat, 26 Oct 2013 15:22:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Steve Dickson <SteveD@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] mountd: disabling turning off TCP listeners (v2)
Message-ID: <20131026192220.GB17945@fieldses.org>
References: <1382638633-6710-1-git-send-email-steved@redhat.com>
 <20131024144507.72aa34a8@tlielax.poochiereds.net>
 <526978BF.7020202@RedHat.com>
 <20131025074316.2affe9e9@tlielax.poochiereds.net>
 <526A62C1.6060803@RedHat.com>
 <20131025142012.GC20497@fieldses.org>
 <526A8BAB.8040704@RedHat.com>
 <20131026185547.GB17487@fieldses.org>
 <nguf78hrh9dsldjd23v6itm6.1382814616803@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <nguf78hrh9dsldjd23v6itm6.1382814616803@email.android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 26, 2013 at 07:10:22PM +0000, Stanislav Kinsbursky wrote:
> Guys, feel free to mail me.
> It's a pure luck that I read this mail...

Hah, sorry, yes, I was been lazy, should have added the cc.

> Yes, different exports for containers definitelly were working in past.
> And, actually, it's not that easy to break this functionaly since there are not special code parts to support sucn exports in containers.

Yes, it's not that I'm worried about it so much as that there are things
I'd like to try using it for.

Though it probably would be a good idea to set up some simple regression
tests.

--b.

> 
> Пользователь "J. Bruce Fields" <bfields@fieldses.org> писал:
> 
> 
> On Fri, Oct 25, 2013 at 11:18:03AM -0400, Steve Dickson wrote:
> > On 25/10/13 10:20, J. Bruce Fields wrote:
> > >> I ideally it would be best not to have mountd at all on NFSv4-only server.
> > >> > Basically, have the kernel get its exports like it gets it ID mappings.
> > >> > Until that day comes, which I hope fill be soon, the TCP listener
> > >> > only effects v3 mounts and we definitely want people to use TCP
> > >> > with v3.
> > > I'm not sure if we want to do that, but note one thing we'll need to do
> > > before then is solve the namespace problems.  (We don't currently have a
> > > good way to run the usermode helper in the right container.)
> >
> > Sorry for not keeping up on the container work and possibly asking
> > dumb question... but there can be different exports per container?
> 
> Yes, definitely.
> 
> > I thought it was just different IPs per container....
> >
> > If so, how does that work today?
> 
> It should work (except possibly for state recovery).  I haven't tested
> it yet, though I hope to.  Stanislav has.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
