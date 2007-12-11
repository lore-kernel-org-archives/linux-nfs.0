From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: sm-notify does not remove its pid file.
Date: Tue, 11 Dec 2007 09:28:27 -0500
Message-ID: <475E9E8B.2060109@RedHat.com>
References: <475D91B9.4070405@RedHat.com>	<18269.49269.575546.943037@notabene.brown>	<475DE62D.7020305@RedHat.com> <18270.992.262485.318331@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728AbXLKO2c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2007 09:28:32 -0500
In-Reply-To: <18270.992.262485.318331-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> Debian has /etc/init.d/bootclean which contains:
> 
> 	cd /var/run ; .....
> 	....
>         find . ! -xtype d ! -name utmp ! -name innd.pid \
>                 -print0 | xargs -0r rm -f -- \
> 		|| ....
> 
> so any files except a select few are removed.
> 
> SLES has /etc/init.d/boot.cleanup which has
>             find /var/run /var/lock -type f -print0 | xargs -0 -r rm -f 2>/dev/null
> 
> so again, all files get removed.
> 
> You seem to be saying that Redhat requires everything in /var/run to
> be explicitly cleaned up ???  Aren't standards wonderful :-)
That appears to be the case... on both Fedora and RHEL... 

> 
> 
>>> And I think the point of the lock file was the sm-notify would only
>>> run once per reboot.  
>> Why impose a limit? Why not recover lock at any point?
> 
> You only want to recover locks when they have been lost.  Boot time is
> that time.
99.9% of time, I agree. But there are times when services are 
restarted without reboots.  

> 
> The particular situation I wanted to handle was that I wanted it to be
> OK to start statd at any time.   And I wanted sm-notify to run at boot
> time if possible, but also to be run when statd was started if it
> hadn't run already.
> An 'I have run already' file in /var/run seemed the obvious solution.
I now do see the logical... But the fact that a file does or does
not exist so should not be the deciding factor of whether a lock is 
or is not recovered.  Shouldn't be the existence (or non-existence) 
of a lock that governs whether a lock is or is not recovered? 


>>> But I think that removing the lock file when sm-notify completes is
>>> wrong.
>> A side effect of all this is if rpc.statd is restarted and that
>> file is not cleaned up the client will never even try to recover any locks. 
>> That's definitely not a good thing... imho... 
> 
> There is no need for a client to recover locks if statd is restarted
> (is there).  I think statd now stores all state in /var/lib/nfs/* so
> if it is killed and restarted, it should pick up exactly where it left
> off.
But if the 'nfslock' service is restarted (i.e. service nfslock restart), 
at least in Fedora and RHEL, the locks need to be reclaimed. 
Of course the init script can arbitrary remove the pid file, but isn't
there (very small) chance that a sm-notify process could be 
still running, hung up in some type of network issue?
 
> 
> The time that you need to notify clients is when *lockd* is
> restarted.  Or more significantly, when lockd arbitrarily drops it's
> locks. 
> i.e. if you "kill -9" lockd, then you need to do something with
> sm-notify and I acknowledge that isn't well documented nor is there an
> automatic procedure to make it happen.  So there is room for
> improvement, but I don't think that running sm-notify every time that
> statd is started is an improvement.
Well, today, sm-notify is run every time statd is started. It just that
sm-notify exits when the pid file exists. Instead maybe what should happen
is sm-notify should exit when there is no work to be done (i.e. no locks
to recover). 

Of course this runs the risk of causing clients to unnecessarily 
reclaiming there locks, but, imho, that's okay! Its the price of
restarted the nfslock service, something that should not happen
too often anyways.

Also shouldn't there be some type of synchronization between 
statd and sm-notify? Meaning should statd wait until sm-notify 
is done doing its work (or at least creating the backup directory)?


> 
>>> Note the comment in sm-notify.c:
>>>
>>> /*
>>>  * Record pid in /var/run/sm-notify.pid
>>>  * This file should remain until a reboot, even if the
>>>  * program exits.
>>>  * If file already exists, fail.
>>>  */
>> I guess I just don't understand why a pid file need to exist after a 
>> process is gone. Especially if its going to cause the next existence 
>> to imminently exit (potentially causing data corruption). 
>> That just does not seem very robust... 
> 
> Maybe making look like a pid file was a mistake.  I'd be OK with
> changing the name to /var/run/sm-notify-has-run or similar.  If we
> could store in the file some reflection of the state of lockd, that
> would be even better, but I don't think such a value is available at
> the moment.
Its just a pet peeve of mine for processes not to clean up after themselves. 
Leaving things around for other process to clean up just never seemed
like a good idea to me.

> 
> What potential for data corruption do you see?
The nfslock service  is restarted, the client locks are lost
and no notification is sent out (because the existence of a
pid file).  This was what I was seeing when I started this thread.

steved.



