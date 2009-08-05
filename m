From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
	part)
Date: Wed, 5 Aug 2009 13:48:11 -0400
Message-ID: <20090805174811.GB9944@fieldses.org>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net> <20090805144540.12866.22084.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36018 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750701AbZHERsP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Aug 2009 13:48:15 -0400
In-Reply-To: <20090805144540.12866.22084.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 05, 2009 at 10:45:40AM -0400, Chuck Lever wrote:
> Provide a new implementation of statd that supports IPv6.  The new
> statd implementation resides under
> 
>   utils/new-statd/
> 
> The contents of this directory are built if --enable-tirpc is set
> on the ./configure command line, and sqlite3 is available on the
> build system.  Otherwise, the legacy version of statd, which still
> resides under utils/statd/, is built.
> 
> The goals of this re-write are:
> 
>  o Support IPv6 networking
> 
>    Support interoperation with TI-RPC-based NSM implementations.
>    Transport Independent RPC, or TI-RPC, provides IPv6 network support
>    for Linux's NSM implementation.
> 
>    To support TI-RPC, open code to construct RPC requests in socket
>    buffers and then schedule them has been replaced with standard
>    library calls.
> 
>  o Support notification via TCP
> 
>    As a secondary benefit of using TI-RPC library calls, reboot
>    notifications and NLM callbacks can now be sent via connection-
>    oriented transport protocols.
> 
>    Note that lockd does not (yet) tell statd what transport protocol
>    to use when sending reboot notifications.  statd/sm-notify will
>    continue to use UDP for the time being.
> 
>  o Use an embedded database for storing on-disk callback data
> 
>    This whole exercise is for the purpose of crash robustness.  There
>    are well-known deficiencies with simple create/rename/unlink
>    disk storage schemes during system crashes.  Replace the current
>    flat-file monitor list mechanism which uses sync(2) with sqlite3,
>    which uses fsync(3).

If someone wants to move around that data, is it still simple to do
that?  (Where is it kept on the filesystem?)

(I'm thinking of someone that shares it for high-availabity, as in:

	http://www.howtoforge.com/high_availability_nfs_drbd_heartbeat_p3

Or maybe somebody that just needs to move their /var partition to a
different disk one day.)

>  o Share code between sm-notify and statd
> 
>    Statd and sm-notify access the same set of on-disk data.  These
>    separate programs now share the same code and implementation, with
>    access to on-disk data serialized by sqlite3.  The two remain
>    separate executables to allow other system facilities to send
>    reboot notifications without poking statd.
> 
>  o Reduce impact of DNS outages
> 
>    The heuristics used by SM_NOTIFY to figure out which remote peer
>    has rebooted are heavily dependent on DNS.  If the DNS service is
>    slow or hangs, that will make the NSM listener unresponsive.
>    Incoming SM_NOTIFY requests are now handled in a sidecar process
>    to reduce the impact of DNS outages on the NSM service listener.
> 
>  o Proper my_name support
> 
>    The current version of statd uses gethostname(3) to generate the
>    mon_name argument of SM_NOTIFY.  This value can change across a
>    reboot.  The new version of statd records lockd's my_name, passed
>    by every SM_MON request, and uses that when sending SM_NOTIFY.
> 
>    This can be useful for multi-homed and DHCP configured hosts.
> 
>  o Send SM_NOTIFY more aggressively
> 
>    It has been recommended that statd/sm-notify send SM_NOTIFY
>    more aggressively (for example, to the entire list returned by
>    getaddrinfo(3)).  Since SM_NOTIFY's reply is NULL, there's no
>    way to tell whether the remote peer recognized the mon_name we
>    sent.  More study is required, but this implementation attempts
>    to send an SM_NOTIFY request to each address returned by
>    getaddrinfo(3).
> 
> This re-implementation paves the way for a number of future
> improvements.  However, it does not immediately address:
> 
>  o lockd/statd start-up serialization issues
> 
>    Sending reboot notifications, starting statd and lockd, and opening
>    the lockd grace period are still determined independently in user
>    space and the kernel.
> 
>  o Binding mon_names to caller IP addresses
> 
>    By default, lockd continues to send IP addresses as the mon_name
>    argument of the SM_MON procedure.  This provides a better guarantee
>    of being able to contact remote peers during a reboot, but means
>    statd must continue to use heuristics to match incoming SM_NOTIFY
>    requests with peers on the monitor list.
> 
>  o Distinct logic for NFS client- and server-side
> 
>    Client-side and server-side monitoring requirements are different.
>    Statd continues to use the same logic for both NFS client and
>    server, as the NSMv1 protocol does not provide any indication
>    that a mon_name is for a client or server peer.

Note we probably don't need to be limited by the protocol here, only by
kernel backwards-compatibility requirements, as long as this is just
kernel<->statd communication and not something that goes across the wire
to other statd implementations.

--b.
