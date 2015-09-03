Return-Path: <shawn.starr@rogers.com>
From: Shawn Starr <shawn.starr@rogers.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [NFSv4.1] Deadlock on writes - RHEL 7.1 kernel - nfs_pageio_doio?
Date: Thu, 03 Sep 2015 11:54:40 -0400
Message-ID: <2932091.5g0LhYZZI5@segfault>
In-Reply-To: <alpine.OSX.2.19.9992.1509030643490.71803@planck.local>
References: <2535588.ljdrthqrNr@segfault> <alpine.OSX.2.19.9992.1509030643490.71803@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
List-ID: <linux-nfs.vger.kernel.org>

On Thursday, September 03, 2015 06:47:26 AM Benjamin Coddington wrote:
> Hi Shawn,
> 
> This doesn't look like a deadlock to me, just processes waiting for their
> writes to complete.  They've been waiting for a long time, so the hung task
> warning is triggered.
> 
> There might be a network problem that's preventing that NFS client from
> communicating with the server, or the server is taking a very long time
> to complete the operation.  A network capture between the client and server
> might show what's actually happening.
> 
> Ben
> 
Hi Ben,

While that might be the case, this does not happen on our RHEL6 and CentOS 6.x VMs
so, I'm hesitant to say it's network related fully.

If EL7 changed some timeouts for NFS then this might explain the hung task warning, however,
leaving the VMs stuck they never recover, they appear deadlocked in VFS subsystem in the fact I can't login into them
via SSH or from the KVM console session itself. So all writes not on local disk are deadlocked
writes to remote syslog appear fine as this isn't going though VFS.

Thanks,
Shawn

> On Wed, 2 Sep 2015, Shawn Starr wrote:
> > Hello NFS devs,
> > 
> > While this is a CentOS/RHEL kernel: 3.10.0-229.4.2.el7.x86_64 (and old)
> > 
> > I was wondering your take on this deadlock, I cannot reproduce this and it
> > seems to happen in our KVM VM images randomly so far only once. When we
> > configure a VM it does two reboots, first sets up things then a final
> > reboot where we have a fresh bootup with settings in place.
> > 
> > 
> > This could be from a cron thats running, but the VMs in question is pretty
> > much idle, CPU skyrockets and they deadlock, can't ssh into them to
> > examine why. We have remote syslog capturing, so I would never see this
> > otherwise.
> > 
> > If anyone has ideas on how I can test this? This has been reported in the
> > CentOS bugtracker by someone else also, I couldn't use their methods for
> > reproduction.
> > 
> > below is the trace from kernel:
> > 
<snip>
