From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] mount.nfs: set the default family for lookups based on
 Defaultproto= setting
Date: Fri, 5 Feb 2010 12:43:40 -0500
Message-ID: <20100205124340.6b77902c@tlielax.poochiereds.net>
References: <1265380055-5650-1-git-send-email-jlayton@redhat.com>
	<4B6C39D0.3030704@oracle.com>
	<20100205113052.333f0c05@tlielax.poochiereds.net>
	<4B6C51A4.3070005@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932165Ab0BERnp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 12:43:45 -0500
In-Reply-To: <4B6C51A4.3070005@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 05 Feb 2010 12:13:08 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi Jeff-
> 
> On 02/05/2010 11:30 AM, Jeff Layton wrote:
> > On Fri, 05 Feb 2010 10:31:28 -0500
> > Chuck Lever<chuck.lever@oracle.com>  wrote:
> >
> >> On 02/05/2010 09:27 AM, Jeff Layton wrote:
> >>> When IPv6 is enabled, the Proto= config file option is treated as a
> >>> netid, and the address family for lookups is selected based on that
> >>> setting. The Defaultproto= option however still only affects the
> >>> protocol setting for the sockets (IPPROTO_*) and not the address family.
> >>>
> >>> This patch makes it so that if someone sets the "Defaultproto=" option
> >>> in the nfsmount.conf, it's used to determine the default address family
> >>> for lookups as well as the protocol type.
> >>>
> >>> This gives users a way to force a particular address family to be used
> >>> universally for mounts and brings the behavior of the Defaultproto=
> >>> option in line with the Proto= option.
> >>>
> >>> Signed-off-by: Jeff Layton<jlayton@redhat.com>
> >>> ---
> >>>    utils/mount/configfile.c |    8 ++++++++
> >>>    utils/mount/network.c    |   18 ++++++++----------
> >>>    2 files changed, 16 insertions(+), 10 deletions(-)
> >>>
> >>> diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
> >>> index 6843098..71d3627 100644
> >>> --- a/utils/mount/configfile.c
> >>> +++ b/utils/mount/configfile.c
> >>> @@ -221,6 +221,8 @@ int inline check_vers(char *mopt, char *field)
> >>>
> >>>    unsigned long config_default_vers;
> >>>    unsigned long config_default_proto;
> >>> +extern sa_family_t config_default_family;
> >>> +
> >>>    /*
> >>>     * Check to see if a default value is being set.
> >>>     * If so, set the appropriate global value which will
> >>> @@ -242,6 +244,12 @@ int inline default_value(char *mopt)
> >>>    				xlog_warn("Unable to set default protocol : %s",
> >>>    					strerror(errno));
> >>>    			}
> >>> +#ifdef IPV6_SUPPORTED
> >>> +			if (!nfs_nfs_proto_family(options,&config_default_family)) {
> >>> +				xlog_warn("Unable to set default family : %s",
> >>> +					strerror(errno));
> >>> +			}
> >>> +#endif
> >>
> >> Maybe you don't need the #ifdef here?
> >>
> >> Aside from making the code more readable, removing the #ifdef would also
> >> make it so the same code path is followed whether IPv6 is supported or
> >> not, which makes testing easier.
> >>
> >> Just a thought.
> >>
> >
> > They probably aren't essential. It all comes down to what we want the
> > behavior to be in the following situation:
> 
> OK... I had thought the behavior would be the same with and without the 
> #ifdef's.  Since it clearly doesn't work the same way in both cases, 
> that's a sure sign that we will have testing and documentation problems 
> here if the #ifdef is left in.
> 
> > If someone had a TIRPC enabled nfs-utils but IPv6 support is disabled,
> > and then set Defaultproto=tcp6.
> >
> > With the ifdef's in place, then the address family part of it would
> > just be ignored. Without those in place, IPv6 will be forced for the
> > lookup but we won't actually be able to make use of the addresses
> > returned.
> 
> As an admin (who understands how netids work), I would be more surprised 
> if setting the default protocol (netid, really) to tcp6, and then 
> disabling IPv6 on the client, or at build time in nfs-utils, or if the 
> IPv6-related netids were missing from /etc/netconfig, would work at all. 
>   It would be more consistent behaviour IMO to make this case fail.
> 
> I agree with having things "just work" in reasonable cases, but it seems 
> like we are bending the semantics of netids and proto= to make that happen.
> 
> "tcp6" does not mean "use IPv6 if it's available."  It means "always use 
> IPv6."  And, "tcp" does not mean "use TCP on either IPv4 or IPv6," it 
> now means "always use TCP on IPv4."  This is what we buy with netids and 
> TI-RPC.  That's why we use HAVE_LIBTIRPC rather than IPV6_SUPPORTED in 
> nfs_nfs_proto_family and nfs_mount_proto_family.
> 
> > Granted, it's a bit of a pathological setup, but I don't think the
> > #ifdef's here really take away anything and may help prevent confusion
> > with the union of all these different options.
> >
> >>>    		} else {
> >>>    			xlog_warn("Unable to alloc memory for default protocol");
> >>>    		}
> >>> diff --git a/utils/mount/network.c b/utils/mount/network.c
> >>> index 92bba2d..0ab3bb1 100644
> >>> --- a/utils/mount/network.c
> >>> +++ b/utils/mount/network.c
> >>> @@ -1331,6 +1331,12 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
> >>>    	return 1;
> >>>    }
> >>>
> >>> +#ifdef IPV6_SUPPORTED
> 
> By the above argument, this should be HAVE_LIBTIRPC.
> 

I can sort of buy the argument for leaving out the earlier #ifdef
around the default_value() function.

If you change this one though, then lookups will still return IPv6
addresses by default even when IPV6_SUPPORTED isn't set. IOW, in the
absence of a proto= option, you'll pass AF_UNSPEC to getaddrinfo and
get IPv6 addresses. I don't think that's what we want here for a
non-ipv6 enabled nfs-utils.


> >>> +sa_family_t	config_default_family = AF_UNSPEC;
> >>> +#else
> >>> +sa_family_t	config_default_family = AF_INET;
> >>> +#endif
> >>> +
> >>>    /*
> >>>     * Returns TRUE and fills in @family if a valid NFS protocol option
> >>>     * is found, or FALSE if the option was specified with an invalid value.
> >>> @@ -1341,11 +1347,7 @@ int nfs_nfs_proto_family(struct mount_options *options,
> >>>    	unsigned long protocol;
> >>>    	char *option;
> >>>
> >>> -#ifdef IPV6_SUPPORTED
> >>> -	*family = AF_UNSPEC;
> >>> -#else
> >>> -	*family = AF_INET;
> >>> -#endif
> >>> +	*family = config_default_family;
> >>>
> >>>    	switch (po_rightmost(options, nfs_transport_opttbl)) {
> >>>    	case 0:	/* udp */
> >>> @@ -1488,11 +1490,7 @@ int nfs_mount_proto_family(struct mount_options *options,
> >>>    	unsigned long protocol;
> >>>    	char *option;
> >>>
> >>> -#ifdef HAVE_LIBTIRPC
> >>> -	*family = AF_UNSPEC;
> >>> -#else
> >>> -	*family = AF_INET;
> >>> -#endif
> >>> +	*family = config_default_family;
> >>>
> >>>    	option = po_get(options, "mountproto");
> >>>    	if (option != NULL)
> >>
> >>
> >
> >
> 


-- 
Jeff Layton <jlayton@redhat.com>
