From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Wed, 11 Feb 2009 07:57:11 -0500
Message-ID: <1234357031.7423.206.camel@heimdal.trondhjem.org>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au>
	 <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com>
	 <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au>
	 <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com>
	 <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au>
	 <1233699391.7161.11.camel@heimdal.trondhjem.org>
	 <91CE7AFB-2B15-4223-BE43-DF95ABC4B195@oracle.com>
	 <1233771633.7161.35.camel@heimdal.trondhjem.org>
	 <5552ED43-5E9C-4136-823D-DDDCF129DFAC@oracle.com>
	 <1233773231.7161.51.camel@heimdal.trondhjem.org>
	 <1234094116.13862.162.camel@sibyl.beware.dropbear.id.au>
	 <7ED0098B-1D71-4E43-A8E4-D5859F13DD38@oracle.com>
	 <1234355861.13862.239.camel@sibyl.beware.dropbear.id.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:40751 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754663AbZBKM5V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Feb 2009 07:57:21 -0500
In-Reply-To: <1234355861.13862.239.camel-+Zt617Lp5ASbJVK1MCa92ZvzqaJJnU0YunOrhLTifxA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-02-11 at 23:07 +1030, Ian Dall wrote:
> On Mon, 2009-02-09 at 16:11 -0500, Chuck Lever wrote:
> > Hi Ian-
> > 
> > On Feb 8, 2009, at 6:55 AM, Ian Dall wrote:
> > > On Wed, 2009-02-04 at 13:47 -0500, Trond Myklebust wrote:
> > >> On Wed, 2009-02-04 at 13:44 -0500, Chuck Lever wrote:
> > >>> Right.  So, then, can nfs_match_client() use the same address
> > >>> comparison method as nfs_find_client()?  I'm inclined to think
> > >>> nfs_match_client() can use a more straightforward address comparison
> > >>> method.
> 
> > > Log:
> > > ======================
> > > sockaddr structures can't be reliably compared using memcmp()
> > > because there are padding bytes in the structure which can't be
> > > guaranteed to be the same even when the sockaddr structures refer to
> > > the same socket.
> > 
> > It is also the case that IPv6 socket address structures contain other  
> > fields that don't have to match, like sin6_scope_id.  I think that is  
> > worth noting in the patch description.
> > 
> > I don't see anything immediately wrong with this approach, but I made  
> > a couple of additional minor comments below.
> > 
> > > Signed-off-by: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
> 
> Apparently this should be "From" (for the author) not "Signed-off-by"
> According to Andrew Morton commenting on a completely different patch.

No. Signed-off-by: is correct at the end of the changelog, however a
'From' as the very first line, helps git track who was the original
author.

> > > ======================
> > > diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> > > index 9b728f3..04b11d9 100644
> > > --- a/fs/nfs/client.c
> > > +++ b/fs/nfs/client.c
> > > @@ -272,6 +272,42 @@ static int nfs_sockaddr_match_ipaddr(const  
> > > struct sockaddr *sa1,
> > > }
> > > #endif
> > >
> > > +/* Test if two socket addresses are the same family, ipaddr and  
> > > port */
> > 
> > Instead of repeating what the function does, can this comment explain  
> > why the NFS client needs to match on the address and port, for example?
> > 
> > Explaining why it is different than the existing  
> > nfs_sockaddr_match_ipaddr() function would be helpful for future  
> > generations.
> 
> Wouldn't this be more appropriate where the function is called? I know
> that it is only called from one place, but still, I would have thought
> the obvious thing to do would be document what a function does where you
> define it and document why you are calling it when you are calling it.
> Either way, I don't actually *know* why we need to match on port number!
> I have to confess no deep understanding of the difference between
> nfs_match_client and nfs_find_client. I only did a bisection to find the
> commit which caused the regression, then fixed it.
> 
> If someone who does understand wants to contribute a description, that's
> fine by me! Following the principle of one change per patch, it may as
> well be a different commit since it would relevant regardless of my
> patch. The current code (with the memcmp) compares everything, it's just
> that it compares too much.
> 
> > As a stylistic point, these days we prefer to use a helper function  
> > instead of curly braces inside the arms of the switch.  It will also  
> > remove the need to fold those lines.
> > 
> > I have used this style in the past, but there is general consensus now  
> > that helper functions are easier to read, and are therefore preferred.
> 
> Yes, I blame it on the prevalence of OO programming where it is routine
> to have a helper functions which to do nothing more than get a field out
> of a structure ;-(  
> 
> Here is a new patch with helper functions, improved ipv6 comparison
> (though I can not test this and my understanding of ipv6 is almost
> certainly incomplete), better comments and a better log entry. 
> 
> Log:
> ======================
> sockaddr structures can't be reliably compared using memcmp()
> because there are padding bytes in the structure which can't be
> guaranteed to be the same even when the sockaddr structures refer to
> the same socket. Instead compare all the relevant fields. These are
> sin_addr and sin_port number for IPv4. In the case of IPv6 they are
> sin6_addr, sin6_port and sin6_scope_id, which is relevant for  link
> local addresses. The sin6_flowinfo field only affects QoS and is not
> compared. 
> 
> From: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
> ======================
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 9b728f3..efdae09 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -272,6 +272,62 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
>  }
>  #endif
>  
> +/* Test if two ip4 socket addresses have the same ipaddr and port number */
> +static int nfs_sockaddr_cmp_ip4 (const struct sockaddr_in * saddr1,
> +			  const struct sockaddr_in * saddr2)
> +{
> +	/* Compare ip4 address */
> +	if (likely(saddr1->sin_addr.s_addr !=
> +		   saddr2->sin_addr.s_addr)) {

I don't think you really want the 'likely()' here. If you only have one
server, then the resulting "optimisation" would be incorrect. I'd
therefore leave it out.

> +		return 0;
> +	}
> +	/* Compare port */
> +	return (saddr1->sin_port == saddr2->sin_port);
> +}
> +
> +/* Test if two ip6 socket addresses have the same ipaddr, scope_id and
> + * port number.
> + */
> +static int nfs_sockaddr_cmp_ip6 (const struct sockaddr_in6 * saddr1,
> +			  const struct sockaddr_in6 * saddr2)
> +{
> +	/* Compare ip6 address */
> +	if (likely(!ipv6_addr_equal(&saddr1->sin6_addr,
> +				    &saddr1->sin6_addr))) {

Ditto...

> +		return 0;
> +	}
> +
> +	/* Compare scope_id. This may only matter for link local
> +	 * addresses, but it is cheap, and should be harmless, to just
> +	 * compare it anyway.
> +	 */
> +	if (saddr1->sin6_scope_id != saddr2->sin6_scope_id)
> +		return 0;
> +	/* Don't compare sin6_flowinfo since it is to do with QoS, but
> +	 * doesn't effect the packets source or destination.
> +	 */ 
> +	/* Compare ports */
> +	return (saddr1->sin6_port == saddr2->sin6_port);
> +}
> +
> +/* Test if two socket addresses represent the same actual socket */
> +static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
> +			      const struct sockaddr *sa2)
> +{
> +	if (sa1->sa_family != sa2->sa_family)
> +		return 0;
> +  
> +	switch (sa1->sa_family) {
> +	case AF_INET:
> +		return nfs_sockaddr_cmp_ip4 ((const struct sockaddr_in *) sa1,
> +					     (const struct sockaddr_in *) sa2);
> +	case AF_INET6:
> +		return nfs_sockaddr_cmp_ip6 ((const struct sockaddr_in6 *) sa1,
> +					     (const struct sockaddr_in6 *) sa2);
> +	}
> +	return 0;
> +}
> +
>  /*
>   * Find a client by IP address and protocol version
>   * - returns NULL if no such client
> @@ -344,8 +400,10 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
>  static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *data)
>  {
>  	struct nfs_client *clp;
> +	const struct sockaddr *sap = data->addr;
>  
>  	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
> +	        const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
>  		/* Don't match clients that failed to initialise properly */
>  		if (clp->cl_cons_state < 0)
>  			continue;
> @@ -358,7 +416,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
>  			continue;
>  
>  		/* Match the full socket address */
> -		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
> +		if (!nfs_sockaddr_cmp(sap, clap))
>  			continue;
>  
>  		atomic_inc(&clp->cl_count);
> 
> 
> 

