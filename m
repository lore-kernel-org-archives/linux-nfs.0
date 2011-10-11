Return-Path: linux-nfs-owner@vger.kernel.org
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:47579 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab1JKGSa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Oct 2011 02:18:30 -0400
Date: Tue, 11 Oct 2011 08:18:19 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@netapp.com, smfrench@gmail.com, rjw@sisk.pl,
        linux-pm@lists.linux-foundation.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, john@Calva.COM,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/4] allow freezing of tasks with netfs calls in flight
Message-ID: <20111011061819.GA1377@ucw.cz>
References: <1317210761-11518-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1317210761-11518-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

> We've had a number of reports recently of people with NFS and CIFS
> mounts that were unable to suspend or hibernate their machines. Here
> are a couple of Fedora bugs that illustrate the problem:
> 
>     https://bugzilla.redhat.com/show_bug.cgi?id=712088
>     https://bugzilla.redhat.com/show_bug.cgi?id=717735
> 
> When it occurs the problem is pretty clear. We have a task that's
> sleeping in the kernel in TASK_KILLABLE sleep, generally waiting
> for a reply to come in. Often though, userspace has already taken
> down the interface so that reply will never come. The process then
> fails to freeze and the suspend fails.

Userspace should not take interface down for suspend (*). Why do that?


> This patch fixes this by allowing the TASK_KILLABLE sleeps in NFS and
> CIFS to be awoken by the freezer and then to try to freeze. If a freeze
> event does occur, then the code will treat it as if a schedule() has
> already occured.

Looks like good idea...

(*) unless absolutely neccessary. openvpn?

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
