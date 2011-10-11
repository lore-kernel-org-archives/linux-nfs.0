Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:47602 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab1JKGTK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Oct 2011 02:19:10 -0400
Date: Tue, 11 Oct 2011 08:18:48 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@netapp.com, smfrench@gmail.com, rjw@sisk.pl,
        linux-pm@lists.linux-foundation.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, john@Calva.COM,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/4] freezer: make fake_signal_wake_up wake
 TASK_KILLABLE tasks too
Message-ID: <20111011061847.GB1377@ucw.cz>
References: <1317210761-11518-1-git-send-email-jlayton@redhat.com>
 <1317210761-11518-2-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1317210761-11518-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi!

> TASK_KILLABLE is often used to put tasks to sleep for quite some time.
> One of the most common uses is to put tasks to sleep while waiting for
> replies from a server on a networked filesystem (such as CIFS or NFS).
> 
> Unfortunately, fake_signal_wake_up does not currently wake up tasks
> that are sleeping in TASK_KILLABLE state. This means that even if the
> code were in place to allow them to freeze while in this sleep, it
> wouldn't work anyway.
> 
> This patch changes this function to wake tasks in this state as well.
> This should be harmless -- if the code doing the sleeping doesn't have
> handling to deal with freezer events, it should just go back to sleep.

I'm pretty sure this will break something; but that does not mean it
is bad idea, just that it should be merged early and tested a lot.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
