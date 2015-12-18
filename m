Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51824 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121AbbLROyQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2015 09:54:16 -0500
Date: Fri, 18 Dec 2015 09:54:13 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Add notifier blocks to close transport sockets when
 an ip address is deleted
Message-ID: <20151218145413.GB25074@fieldses.org>
References: <1449870360-23319-1-git-send-email-smayhew@redhat.com>
 <20151217195708.GA16808@fieldses.org>
 <20151218135541.GO4405@tonberry.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151218135541.GO4405@tonberry.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 18, 2015 at 08:55:41AM -0500, Scott Mayhew wrote:
> On Thu, 17 Dec 2015, J. Bruce Fields wrote:
> 
> > On Fri, Dec 11, 2015 at 04:45:57PM -0500, Scott Mayhew wrote:
> > > For this to be effective, the clients still need to mount with a lower timeout,
> > > but it doesn't need to be as aggressive as 1/10 of a second.
> > 
> > That's just to prevent a file operation hanging too long in the case
> > that nfsd or ip shutdown prevents the client getting a reply?
> 
> That statement was based on early testing actually.  I went on to test 
> with timeouts of 3, 10, 30, and 60 seconds, and it no longer appeared to
> make a difference.  I just forgot to remove that from my final cover
> letter.

OK.  Though the window to hit the lost-reply case might be very small,
I'm not sure.

--b.
