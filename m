From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 00/24] Remaining IPv6 patches for statd
Date: Sat, 16 Jan 2010 08:22:22 -0500
Message-ID: <4B51BD8E.5060106@RedHat.com>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936Ab0APNW0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Jan 2010 08:22:26 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/14/2010 12:28 PM, Chuck Lever wrote:
> The Fedora 13 feature freeze is next week, and RHEL 6 beta is coming
> up in just a month or two.  Because both of these releases should have
> at least client-side NFS/IPv6 support, we've decided to accelerate the
> submission of nfs-utils IPv6 patches.
> 
> This patch set introduces basic IPv6 support to statd and sm-notify.
> Functionality when IPv6 and TI-RPC are disabled should be unchanged,
> except that monitor record files can now contain more than one line.
> 
> ---
> 
> Chuck Lever (24):
>       statd: update rpc.statd(8) and sm-notify(8) to reflect IPv6 support
>       statd: Support TI-RPC statd listener
>       libnsm.a: retain CAP_NET_BIND when dropping privileges
>       statd: Remove NL_ADDR() macro
>       statd: Support IPv6 in sm_stat_1_svc()
>       statd: Support IPv6 in sm_mon_1_svc()
>       statd: Add API to canonicalize mon_names
>       libnsm.a: Add support for multiple lines in monitor record files
>       libnsm.a: Factor atomic write code out of nsm_get_state()
>       sm-notify: Save mon_name and my_name strings
>       statd: Support IPv6 in sm_simu_crash_1_svc
>       statd: Support IPv6 is caller_is_localhost()
>       statd: add IPv6 support in sm_notify_1_svc()
>       statd: add nsm_present_address() API
>       statd: Introduce statd version of matchhostname()
>       nfs-utils: Collect socket address helpers into one location
>       sm-notify: Support IPv6 DNS lookups in smn_lookup
>       sm-notify: Use getaddrinfo(3) to create bind address in smn_create_socket()
>       sm-notify: IPv6 support in reserved port binding in smn_create_socket()
>       sm-notify: Support creating a PF_INET6 socket in smn_create_socket()
>       sm-notify: factor socket creation out of notify()
>       statd: Update rmtcall.c
>       sm-notify: Replace RPC code
>       libnsm.a: Add RPC construction helper functions
> 
Committed...

steved.
