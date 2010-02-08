From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] mount.nfs: return error if proto= option specified IPv6
 when IPv6 isn't supported
Date: Mon, 8 Feb 2010 12:43:12 -0500
Message-ID: <20100208124312.68087e78@tlielax.poochiereds.net>
References: <1265649242-5063-1-git-send-email-jlayton@redhat.com>
	<4B70497C.909@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753034Ab0BHRnX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 12:43:23 -0500
In-Reply-To: <4B70497C.909@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 08 Feb 2010 12:27:24 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> On 02/08/2010 12:14 PM, Jeff Layton wrote:
> > Right now, there's nothing that expressly forbids someone from
> > specifying proto=tcp6 for instance, even when nfs-utils it built without
> > IPv6 support. This may not work well if (for instance) they are using
> > NFSv3, since statd won't support IPv6. Explicitly return an error if
> > someone specifies an IPv6 proto= or mountproto= option and IPv6 isn't
> > supported.
> >
> > Signed-off-by: Jeff Layton<jlayton@redhat.com>
> > ---
> >   utils/mount/network.c |   34 +++++++++++++++++++++++++++-------
> >   1 files changed, 27 insertions(+), 7 deletions(-)
> >
> > diff --git a/utils/mount/network.c b/utils/mount/network.c
> > index c400dd8..ad165f4 100644
> > --- a/utils/mount/network.c
> > +++ b/utils/mount/network.c
> > @@ -1334,9 +1334,26 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
> >
> >   #ifdef IPV6_SUPPORTED
> >   sa_family_t	config_default_family = AF_UNSPEC;
> > -#else
> > +
> > +static int
> > +nfs_verify_family(sa_family_t family)
> > +{
> > +	return 1;
> > +}
> > +#else /* IPV6_SUPPORTED */
> >   sa_family_t	config_default_family = AF_INET;
> > -#endif
> > +
> > +static int
> > +nfs_verify_family(sa_family_t family)
> > +{
> > +	if (family != AF_INET) {
> > +		errno = EAFNOSUPPORT;
> > +		return 0;
> 
> I assume you do this so that mount.nfs emits a proper error message in 
> this case.  What about below where nfs_get_proto() returns false?
> 

Yep, otherwise if you specify a "Defaultproto=tcp6" in the config file,
you'll get:

mount.nfs: Unable to set default family : Success

...which is a little confusing.

I'm not sure what to do about nfs_get_proto returning false. default_value()
calls this before the address family stuff:

                        if (!nfs_nfs_protocol(options, &config_default_proto)) {
                                xlog_warn("Unable to set default protocol : %s",
                                        strerror(errno));
                        }

...and I assume that it'll also always display "Success" there too,
since errno doesn't seem to be set by nfs_get_proto. Maybe
nfs_get_proto() should set errno?

Again though, that sort of seems like a separate patch from this.

> > +	}
> > +
> > +	return 1;
> > +}
> > +#endif /* IPV6_SUPPORTED */
> >
> >   /*
> >    * Returns TRUE and fills in @family if a valid NFS protocol option
> > @@ -1357,15 +1374,15 @@ int nfs_nfs_proto_family(struct mount_options *options,
> >   		return 1;
> >   	case 2: /* proto */
> >   		option = po_get(options, "proto");
> > -		if (option != NULL)
> > -			return nfs_get_proto(option, family,&protocol);
> > +		if (option != NULL&&  !nfs_get_proto(option, family,&protocol))
> > +			return 0;
> >   	}
> >
> >   	/*
> >   	 * NFS transport protocol wasn't specified.  Return the
> >   	 * default address family.
> >   	 */
> 
> It would help if this comment mentioned why you need to verify *family 
> in the default case.
> 
> > -	return 1;
> > +	return nfs_verify_family(*family);

I suppose we don't really need to check it for the default case. I just
did that since it made fewer conditionals in the code. I can reorganize
it so that it's not needed if that'll be clearer.

> >   }
> >
> >   /*
> > @@ -1494,8 +1511,11 @@ int nfs_mount_proto_family(struct mount_options *options,
> >   	*family = config_default_family;
> >
> >   	option = po_get(options, "mountproto");
> > -	if (option != NULL)
> > -		return nfs_get_proto(option, family,&protocol);
> > +	if (option != NULL) {
> > +		if (!nfs_get_proto(option, family,&protocol))
> > +			return 0;
> > +		return nfs_verify_family(*family);
> > +	}
> >
> >   	/*
> >   	 * MNT transport protocol wasn't specified.  If the NFS
> 


-- 
Jeff Layton <jlayton@redhat.com>
