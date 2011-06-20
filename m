Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167Ab1FTTij (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jun 2011 15:38:39 -0400
Date: Mon, 20 Jun 2011 15:38:34 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: Re: [PATCH] manpage: add info about IPv6 configuration to
 exports(5)
Message-ID: <20110620153834.126e6bbc@tlielax.poochiereds.net>
In-Reply-To: <1308597604-1198-1-git-send-email-jlayton@redhat.com>
References: <1308597604-1198-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 20 Jun 2011 15:20:04 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> The parts of the exports(5) manpage that discuss IP addressing neglect
> IPv6 configuration. Update to include info on how to export to IPv6
> subnets and addresses, and add a line demonstrating that to the EXAMPLE
> section.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/exportfs/exports.man |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
> index 241b3af..cf5f365 100644
> --- a/utils/exportfs/exports.man
> +++ b/utils/exportfs/exports.man
> @@ -47,7 +47,7 @@ NFS clients may be specified in a number of ways:
>  .IP "single host
>  This is the most common format. You may specify a host either by an
>  abbreviated name recognized be the resolver, the fully qualified domain
> -name, or an IP address.
> +name, an IPv4 address, or an IPv6 address enclosed in square brackets.
>  .IP "IP networks
>  You can also export directories to all hosts on an IP (sub-) network
>  simultaneously. This is done by specifying an IP address and netmask pair
> @@ -57,7 +57,7 @@ where the netmask can be specified in dotted-decimal format, or as a
>  contiguous mask length.
>  For example, either `/255.255.252.0' or `/22' appended
>  to the network base IPv4 address results in identical subnetworks with 10 bits of
> -host. Wildcard characters generally do not work on IP addresses, though they
> +host. IPv6 addresses must use a contiguous mask length and be enclosed in square brackets. Wildcard characters generally do not work on IP addresses, though they
>  may work by accident when reverse DNS lookups fail.
>  .IP "wildcards
>  Machine names may contain the wildcard characters \fI*\fR and \fI?\fR.
> @@ -486,6 +486,7 @@ The format for extra export tables is the same as
>  /home/joe       pc001(rw,all_squash,anonuid=150,anongid=100)
>  /pub            *(ro,insecure,all_squash)
>  /srv/www        \-sync,rw server @trusted @external(ro)
> +/foo            [2001:321:9:e54::/64](rw) 192.168.1.0/24(rw)
>  '''/pub/private    (noaccess)
>  .fi
>  .PP
> @@ -501,7 +502,8 @@ option in this entry also allows clients with NFS implementations that
>  don't use a reserved port for NFS.
>  The sixth line exports a directory read-write to the machine 'server'
>  as well as the `@trusted' netgroup, and read-only to netgroup `@external',
> -all three mounts with the `sync' option enabled.
> +all three mounts with the `sync' option enabled. The seventh line exports
> +a directory to both an IPv6 and an IPv4 subnet.
>  ''' The last line denies all NFS clients
>  '''access to the private directory.
>  '''.SH CAVEATS

Self NAK on this, as brackets don't seem to be required after all. I'll
respin and resend once I get that straightened out.

-- 
Jeff Layton <jlayton@redhat.com>
