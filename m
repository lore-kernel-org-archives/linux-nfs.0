Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753754Ab0A0SmQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jan 2010 13:42:16 -0500
Message-ID: <4B608905.90708@RedHat.com>
Date: Wed, 27 Jan 2010 13:42:13 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: Don't fail mounts when /etc/netconfig is nonexistent
References: <4B606CA5.2090607@RedHat.com> <4B60816E.5070108@oracle.com>
In-Reply-To: <4B60816E.5070108@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/27/2010 01:09 PM, Chuck Lever wrote:
>> Author: Steve Dickson<steved@redhat.com>
>> Date:   Wed Jan 27 11:19:00 2010 -0500
>>
>>      In a very sparse environments certain system files (like
>>      /etc/netconfig) may not exist. In these environments don't
>>      fail mount if all the need information (like network protocols)
>>      exist and are well known.
>>
>>      Signed-off-by: Steve Dickson<steved@redhat.com>
> 
> I totally disagree with this.  If HAVE_LIBTIRPC is set, then the runtime
> TI-RPC package should be installed, in its entirety, on the run-time
> systems.  If autoconf and RPM can't trust the given dependency
> information, then all bets are off.
Well in some environments "all bets are off" is just not good enough...
Mount has always worked in these type of  environments before and 
I think we should continue to... 

> 
> The right fix is to either:
> 
> a) install a non-TI-RPC version of mount.nfs, or
> 
> b) make sure /etc/netconfig is available when RPM, pkgconfig, and
> autoconf say it should be.
> 
Sparse environments generally have a finite amount of space, that
is simple unchangeable... so the above "luxuries" are simply not 
available...

> 
> I assume since you are not patching other parts of mount.nfs that look
> for /etc/rpc and /etc/protocols that these files _do_ exist?  Or does
> glibc also do this hack of filling in well-known values?
> 
Lets keep this in perspective... the "well-known" values in this patch
things like TCP and UDP... when protocol == IPPROTO_TCP the well known value
is "tcp" (or "tcp6" depending on the family)... Values that have not 
changed for years and will not change for years... 

On the umount side, the file should not be consulted in the first place
since all the information needed in /etc/mtab... Of course things
can change between mount and umounts but I truly do no think the
meaning of "udp" will change from being IPPROTO_UDP....

Making mount more bullet proof and allowing it (continue to) work in all 
different types of environments is a good thing... imho...

steved.

