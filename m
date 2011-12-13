Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f46.google.com ([209.85.210.46]:57403 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820Ab1LMJlg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Dec 2011 04:41:36 -0500
Received: by dajs34 with SMTP id s34so2565047daj.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Dec 2011 01:41:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111201180950.GA6845@fieldses.org>
References: <CAHbZLqTLHo7FYKmLUbi5OP4=8_O+obOvtFR=6+Dfs+tozJiwKA@mail.gmail.com>
	<20111201180950.GA6845@fieldses.org>
Date: Tue, 13 Dec 2011 15:11:36 +0530
Message-ID: <CAHbZLqS-SHzFcsq+Ehnti6cKqhXKmJNbZDW0P+1sJbmb_eZb1A@mail.gmail.com>
Subject: Re: need help for locking with nfs4
From: Upendra Moturi <upendra.m@hexagrid.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

i want  file to be locked and not accessed even from another nfs client.


On Thu, Dec 1, 2011 at 11:39 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Thu, Dec 01, 2011 at 03:43:03PM +0530, Upendra Moturi wrote:
> > Hi
> >
> > I need some example to configure nfs4 mandatory locking.
> > I have setup nfs4 server and client.
> > I want to enable mandatory locking so that no two clients can access
> > file at same time.
>
> What exactly do you mean by "mandatory locking", and why isn't advisory
> fcntl-based locking sufficient?
>
> --b.




--
Thanks and Regards,
Upendra.M

As a leading developer of IT infrastructure software solutions,
Hexagrid developed the first cloud computing platform that directly
aligns with the real-world IT delivery models of both solution
providers and enterprises. Hexagrid provides all the software and
support that IT organizations need to successfully build public,
private, or hybrid clouds that fit their specific business and
end-user requirements. Hexagrid cloud solutions truly simplify and
expedite virtual IT management, empowering successful cloud computing
strategies that quickly increase profits by pooling resources,
delivering control, and building value. Our Software, Your Cloud.  For
more information, visit www.hexagrid.com and follow @Hexagrid on
Twitter
