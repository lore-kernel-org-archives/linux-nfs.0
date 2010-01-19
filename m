From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] mount.nfs: prefer IPv4 addresses over IPv6 (try #2)
Date: Tue, 19 Jan 2010 15:38:26 -0500
Message-ID: <20100119153826.67dd97a5@tlielax.poochiereds.net>
References: <1263907662-19107-1-git-send-email-jlayton@redhat.com>
	<1667647A-2BB1-478D-8881-CE8EA2191F97@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
	trond.myklebust@fys.uio.no
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9391 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753122Ab0ASUii (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jan 2010 15:38:38 -0500
In-Reply-To: <1667647A-2BB1-478D-8881-CE8EA2191F97@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 19 Jan 2010 10:43:34 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jan 19, 2010, at 8:27 AM, Jeff Layton wrote:
> 
> > We're poised to enable IPv6 in nfs-utils in distros. There is a
> > potential problem however. mount.nfs will prefer IPv6 addrs.
> >
> > If someone has a working IPv4 server today that has an IPv6 address,
> > then clients may start trying to mount over that address. If the  
> > server
> > doesn't support NFS serving over IPv6 (and virtually no linux servers
> > currently do), then the mount will start failing.
> >
> > Avoid this problem by making the mount code prefer IPv4 addresses
> > when they are available and an address family isn't specified.
> >
> > This is the second attempt at this patch. This moves the changes
> > into nfs_validate_options. Chuck also mentioned parameterizing this
> > behavior too. This patch doesn't include that, as I wasn't exactly
> > clear on what he had in mind.
> >
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > utils/mount/stropts.c |   32 +++++++++++++++++++++++++-------
> > 1 files changed, 25 insertions(+), 7 deletions(-)
> >
> > diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> > index 57a4b32..f0937a2 100644
> > --- a/utils/mount/stropts.c
> > +++ b/utils/mount/stropts.c
> > @@ -326,6 +326,29 @@ static int nfs_set_version(struct nfsmount_info  
> > *mi)
> > 	return 1;
> > }
> >
> > +static int nfs_addr_option_lookup(struct nfsmount_info *mi)
> > +{
> > +	struct sockaddr *sap = &mi->address.sa;
> > +	sa_family_t family;
> > +
> > +	if (!nfs_nfs_proto_family(mi->options, &family))
> > +		return 0;
> 
> The real problem is that nfs_nfs_proto_family() returns AF_UNSPEC if  
> "proto=" was not specified. 

...and if it was built with libtirpc support.

> The negotiation logic here in this file  
> can't handle that return properly.
> 
> We could change nfs_nfs_proto_family(), or we could decide that  
> returning AF_UNSPEC is the right thing to do when "proto=" isn't  
> specified.  If the latter, then nfs_nfs_proto_family() (and  
> nfs_mount_proto_family) should get a documenting comment that  
> describes the meaning of the AF_UNSPEC return.
> 

Yep, and we also will need to fix it up for the non-libtirpc case.

> Also, do you need to look at how nfs_mount_proto_family is used in  
> other nearby routines?  It has the same problem.  What do you do when  
> "mountproto=udp6" is specified?
>

That is a problem we'll have to deal with, yes...

> > +
> > +	mi->salen = sizeof(mi->address);
> > +
> > +#ifdef IPV6_SUPPORTED
> > +	/*
> > +	 * A lot of servers don't support NFS over IPv6 yet. For now,
> > +	 * IPv4 addresses are preferred.
> > +	 */
> 
> I think that doesn't describe this workaround adequately.  This is a  
> temporary crutch that prevents us from using IPv6 if "proto=" isn't  
> specified.  The underlying problem here is that nfs_lookup() returns  
> just one address.
> 

Yes. The best solution would be to somehow try all addresses in the
list until one works. That's a larger project however and we'll
probably need some significant kernel changes to handle that anyway.

> > +	if (family == AF_UNSPEC &&
> > +	    nfs_lookup(mi->hostname, AF_INET, sap, &mi->salen))
> > +		return 1;
> > +#endif /* IPV6_SUPPORTED */
> > +
> > +	return nfs_lookup(mi->hostname, family, sap, &mi->salen);
> > +}
> > +
> > /*
> >  * Set up mandatory non-version specific NFS mount options.
> >  *
> > @@ -333,16 +356,11 @@ static int nfs_set_version(struct  
> > nfsmount_info *mi)
> >  */
> > static int nfs_validate_options(struct nfsmount_info *mi)
> > {
> > -	struct sockaddr *sap = &mi->address.sa;
> > -	sa_family_t family;
> >
> > 	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
> > 		return 0;
> >
> > -	if (!nfs_nfs_proto_family(mi->options, &family))
> > -		return 0;
> > -	mi->salen = sizeof(mi->address);
> > -	if (!nfs_lookup(mi->hostname, family, sap, &mi->salen))
> > +	if (!nfs_addr_option_lookup(mi))
> > 		return 0;
> >
> > 	if (!nfs_set_version(mi))
> > @@ -351,7 +369,7 @@ static int nfs_validate_options(struct  
> > nfsmount_info *mi)
> > 	if (!nfs_append_sloppy_option(mi->options))
> > 		return 0;
> >
> > -	if (!nfs_append_addr_option(sap, mi->salen, mi->options))
> > +	if (!nfs_append_addr_option(&mi->address.sa, mi->salen, mi- 
> > >options))
> > 		return 0;
> >
> > 	return 1;
> > -- 
> > 1.6.5.2
> >
> 


-- 
Jeff Layton <jlayton@redhat.com>
