From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: sm-notify does not remove its pid file.
Date: Mon, 10 Dec 2007 20:21:49 -0500
Message-ID: <475DE62D.7020305@RedHat.com>
References: <475D91B9.4070405@RedHat.com> <18269.49269.575546.943037@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbXLKB0T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 20:26:19 -0500
In-Reply-To: <18269.49269.575546.943037-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> I was under the impression that /var/run was always cleaned out on
> reboot, so this shouldn't be a problem.  Is my impression wrong?
I don't think there are any guarantees about this. I was under
the impression that the individual init scripts were suppose 
to clean those up and I know I fixed a few bugs in that area. ;-)

> 
> And I think the point of the lock file was the sm-notify would only
> run once per reboot.  
Why impose a limit? Why not recover lock at any point?

> But I think that removing the lock file when sm-notify completes is
> wrong.
A side effect of all this is if rpc.statd is restarted and that
file is not cleaned up the client will never even try to recover any locks. 
That's definitely not a good thing... imho... 

> 
> Note the comment in sm-notify.c:
> 
> /*
>  * Record pid in /var/run/sm-notify.pid
>  * This file should remain until a reboot, even if the
>  * program exits.
>  * If file already exists, fail.
>  */
I guess I just don't understand why a pid file need to exist after a 
process is gone. Especially if its going to cause the next existence 
to imminently exit (potentially causing data corruption). 
That just does not seem very robust... 

steved.

