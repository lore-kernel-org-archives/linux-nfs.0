Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33299 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754425Ab1LMOUq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Dec 2011 09:20:46 -0500
Date: Tue, 13 Dec 2011 09:20:45 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Upendra Moturi <upendra.m@hexagrid.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: need help for locking with nfs4
Message-ID: <20111213142045.GA28395@fieldses.org>
References: <CAHbZLqTLHo7FYKmLUbi5OP4=8_O+obOvtFR=6+Dfs+tozJiwKA@mail.gmail.com>
 <20111201180950.GA6845@fieldses.org>
 <CAHbZLqS-SHzFcsq+Ehnti6cKqhXKmJNbZDW0P+1sJbmb_eZb1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHbZLqS-SHzFcsq+Ehnti6cKqhXKmJNbZDW0P+1sJbmb_eZb1A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 13, 2011 at 03:11:36PM +0530, Upendra Moturi wrote:
> i want  file to be locked and not accessed even from another nfs client.

The Linux client and server don't really support mandatory locking.

If that's a problem, then we'd need to understand why exactly you need
this, and why advisory locking isn't sufficient.

--b.

> 
> 
> On Thu, Dec 1, 2011 at 11:39 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Thu, Dec 01, 2011 at 03:43:03PM +0530, Upendra Moturi wrote:
> > > Hi
> > >
> > > I need some example to configure nfs4 mandatory locking.
> > > I have setup nfs4 server and client.
> > > I want to enable mandatory locking so that no two clients can access
> > > file at same time.
> >
> > What exactly do you mean by "mandatory locking", and why isn't advisory
> > fcntl-based locking sufficient?
> >
> > --b.
> 
> 
> 
> 
> --
> Thanks and Regards,
> Upendra.M
> 
> As a leading developer of IT infrastructure software solutions,
> Hexagrid developed the first cloud computing platform that directly
> aligns with the real-world IT delivery models of both solution
> providers and enterprises. Hexagrid provides all the software and
> support that IT organizations need to successfully build public,
> private, or hybrid clouds that fit their specific business and
> end-user requirements. Hexagrid cloud solutions truly simplify and
> expedite virtual IT management, empowering successful cloud computing
> strategies that quickly increase profits by pooling resources,
> delivering control, and building value. Our Software, Your Cloud.  For
> more information, visit www.hexagrid.com and follow @Hexagrid on
> Twitter
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
