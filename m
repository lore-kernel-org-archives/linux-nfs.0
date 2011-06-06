From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs-utils: add client match order information to
 exports.man
Date: Mon, 6 Jun 2011 14:30:54 -0400
Message-ID: <20110606183054.GC1151@fieldses.org>
References: <4DECC5B6.8040009@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757457Ab1FFSaz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jun 2011 14:30:55 -0400
In-Reply-To: <4DECC5B6.8040009-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 06, 2011 at 01:19:02PM +0100, James Pearson wrote:
> Add details to the exports man page on the client match order
> against the various Machine Name Format specifications.

Looks good to me.--b.

> 
> Signed-off-by: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
> 
> --- a/utils/exportfs/exports.man        2010-09-28 13:24:16.000000000 +0100
> +++ b/utils/exportfs/exports.man        2011-06-05 22:57:55.232662000 +0100
> @@ -45,22 +45,8 @@
>  .SS Machine Name Formats
>  NFS clients may be specified in a number of ways:
>  .IP "single host
> -This is the most common format. You may specify a host either by an
> -abbreviated name recognized be the resolver, the fully qualified domain
> -name, or an IP address.
> -.IP "netgroups
> -NIS netgroups may be given as
> -.IR @group .
> -Only the host part of each
> -netgroup members is consider in checking for membership.  Empty host
> -parts or those containing a single dash (\-) are ignored.
> -.IP "wildcards
> -Machine names may contain the wildcard characters \fI*\fR and \fI?\fR.
> -This can be used to make the \fIexports\fR file more compact; for instance,
> -\fI*.cs.foo.edu\fR matches all hosts in the domain
> -\fIcs.foo.edu\fR.  As these characters also match the dots in a domain
> -name, the given pattern will also match all hosts within any subdomain
> -of \fIcs.foo.edu\fR.
> +You may specify a host either by an abbreviated name recognized be the
> +resolver, the fully qualified domain name, or an IP address.
>  .IP "IP networks
>  You can also export directories to all hosts on an IP (sub-) network
>  simultaneously. This is done by specifying an IP address and netmask pair
> @@ -72,6 +58,25 @@
>  to the network base IPv4 address results in identical subnetworks
> with 10 bits of
>  host. Wildcard characters generally do not work on IP addresses,
> though they
>  may work by accident when reverse DNS lookups fail.
> +.IP "wildcards
> +Machine names may contain the wildcard characters \fI*\fR and \fI?\fR.
> +This can be used to make the \fIexports\fR file more compact; for instance,
> +\fI*.cs.foo.edu\fR matches all hosts in the domain
> +\fIcs.foo.edu\fR.  As these characters also match the dots in a domain
> +name, the given pattern will also match all hosts within any subdomain
> +of \fIcs.foo.edu\fR.
> +.IP "netgroups
> +NIS netgroups may be given as
> +.IR @group .
> +Only the host part of each
> +netgroup members is consider in checking for membership.  Empty host
> +parts or those containing a single dash (\-) are ignored.
> +.IP "anonymous
> +This is specified by a single
> +.I *
> +character (not to be confused with the
> +.I wildcard
> +entry above) and will match all clients.
>  '''.TP
>  '''.B =public
>  '''This is a special ``hostname'' that identifies the given directory name
> @@ -92,6 +97,12 @@
>  '''.B \-\-public\-root
>  '''option. Multiple specifications of a public root will be ignored.
>  .PP
> +If a client matches more than one of the specifications above, then
> +the first match from the above list order takes precedence - regardless of
> +the order they appear on the export line. However, if a client matches
> +more than one of the same type of specification (e.g. two netgroups),
> +then the first match from the order they appear on the export line takes
> +precedence.
>  .SS RPCSEC_GSS security
>  You may use the special strings "gss/krb5", "gss/krb5i", or "gss/krb5p"
>  to restrict access to clients using rpcsec_gss security.  However, this
