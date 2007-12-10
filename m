From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils: sm-notify does not remove its pid file.
Date: Tue, 11 Dec 2007 09:40:53 +1100
Message-ID: <18269.49269.575546.943037@notabene.brown>
References: <475D91B9.4070405@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:42363 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827AbXLJWk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 17:40:57 -0500
In-Reply-To: message from Steve Dickson on Monday December 10
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday December 10, SteveD@redhat.com wrote:
> It turns out that the sm-notify command, used to notify clients that
> they need to reclaim their locks because the server just changed
> state, does not clean up its pid file. The pid file is used to ensure
> only one instance of the process is running. This results in sm-notify 
> exiting before notifying any clients on the second reboot.
> 
> I also changed the directory in which the pid file is created from
> /var/run into BASEDIR so the file can be removed after the after the 
> user id is changed to a non-root uid.

I was under the impression that /var/run was always cleaned out on
reboot, so this shouldn't be a problem.  Is my impression wrong?

And I think the point of the lock file was the sm-notify would only
run once per reboot.  You really wont it once per
lockd-forgets-all-locks so a kill -9 on lockd should be combined with
removing the lock file.  

But I think that removing the lock file when sm-notify completes is
wrong.

Note the comment in sm-notify.c:

/*
 * Record pid in /var/run/sm-notify.pid
 * This file should remain until a reboot, even if the
 * program exits.
 * If file already exists, fail.
 */


NeilBrown
