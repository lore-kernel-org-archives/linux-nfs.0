From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/6] IPv6 support for nfs-utils tcpwrapper shim (take
 2)
Date: Sun, 17 Jan 2010 20:54:49 -0500
Message-ID: <4B53BF69.80801@RedHat.com>
References: <20100115212102.18214.19398.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072Ab0ARByy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Jan 2010 20:54:54 -0500
In-Reply-To: <20100115212102.18214.19398.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/15/2010 04:31 PM, Chuck Lever wrote:
> These patches provide IPv6 support for the tcpwrapper shim inside
> nfs-utils.
> 
> We've confirmed that libwrap.a (at least the version included in
> Fedora 12) does support IPv6.  Some of the man pages are missing some
> updates.
> 
> I've constructed some simple unit tests using an old program that can
> send bogus SM_NOTIFY requests.  Switching hostnames and IPv6 addresses
> in and out of /etc/hosts.{allow,deny} shows this code with my patches
> to be operating as designed, for basic scenarios.
> 
> I also added more verbose logging in from_local() to confirm how the
> new getifaddrs(3) code is working.  No unpleasant surprises there.
> 
> Testing resulted in no operational changes to the logic in any of
> these patches, but the extra logging seemed worth including, hence
> this redrive.
> 
> ---
> 
> Chuck Lever (6):
>       tcpwrapper: Add support for IPv6
>       tcpwrapper: Eliminated shadowed declaration warnings
>       tcpwrapper: Fix signage problems in the tcp_wrappers hash function
>       tcp_wrapper: Clean up logit()
>       tcp_wrappers: Use getifaddrs(3) if it is available
>       tcpwrappers: Use xlog() instead of perror(3) and syslog(2)
> 
Committed...

steved.
