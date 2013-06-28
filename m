Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755339Ab3F1PSM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Jun 2013 11:18:12 -0400
Date: Fri, 28 Jun 2013 11:18:07 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Weston.Adamson@netapp.com
Subject: Re: [PATCH v4 3/4] nfs: have nfs_mount fake up a auth_flavs list
 when the server didn't provide it
Message-ID: <20130628111807.1e556211@tlielax.poochiereds.net>
In-Reply-To: <077289D0-868D-4358-A29A-8BC31C6FB2F0@oracle.com>
References: <1372362881-32282-1-git-send-email-jlayton@redhat.com>
	<1372362881-32282-4-git-send-email-jlayton@redhat.com>
	<077289D0-868D-4358-A29A-8BC31C6FB2F0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 28 Jun 2013 11:06:08 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jun 27, 2013, at 3:54 PM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Instead of handling this as a special case in the auth-selection code,
> > we can simply fake up an auth_flavs list when the server doesn't
> > provide it.
> 
> The series looks like a reasonable approach.  One nit picked below.
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfs/mount_clnt.c | 18 +++++++++++++++++-
> > fs/nfs/super.c      | 13 -------------
> > 2 files changed, 17 insertions(+), 14 deletions(-)
> > 
> > diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> > index 91a6faf..0f925f3 100644
> > --- a/fs/nfs/mount_clnt.c
> > +++ b/fs/nfs/mount_clnt.c
> > @@ -139,7 +139,10 @@ struct mnt_fhstatus {
> >  * nfs_mount - Obtain an NFS file handle for the given host and path
> >  * @info: pointer to mount request arguments
> >  *
> > - * Uses default timeout parameters specified by underlying transport.
> > + * Uses default timeout parameters specified by underlying transport. On
> > + * successful return, the auth_flavs list and auth_flav_len will be populated
> > + * with the list from the server or a faked-up list if the server didn't
> > + * provide one.
> >  */
> > int nfs_mount(struct nfs_mount_request *info)
> > {
> > @@ -195,6 +198,19 @@ int nfs_mount(struct nfs_mount_request *info)
> > 	dprintk("NFS: MNT request succeeded\n");
> > 	status = 0;
> > 
> > +	/*
> > +	 * The NFSv2 MNT operation does not return a flavor list. Also, some
> > +	 * NFSv3 servers (older Linux servers in particular) return an empty
> > +	 * list.
> > +	 *
> > +	 * In that event fake up a list that just has RPC_AUTH_NULL in it since
> > +	 * we have no way to know what the server actually supports.
> > +	 */
> 
> I see the checks are folded together again.  I'm not going to win that battle, am I? ;-)
> 

Yeah, sorry...

In the other case it made sense since we just did a "goto".

Here, it's either fold the checks together, repeat the list fakeup code
twice, do some goto shenanigans, or stick the list fakeup in a separate
function.

This seemed like the lesser of evils.

> The comment repeats most of what the code already says.  How about:
> 
> 	/*
> 	 * If the server didn't provide a flavor list, allow the
> 	 * client to try any flavor.
> 	 */
> 

Sounds reasonable. I'll fix it up in my repo. I hate to repost it again
for a comment change, so maybe Trond can fix that up if he finds the
series otherwise acceptable?

> Blue is my favorite color, by the way.
> 
> > +	if (info->version != NFS_MNT3_VERSION || *info->auth_flav_len == 0) {
> > +		dprintk("NFS: Faking up auth_flavs list\n");
> > +		info->auth_flavs[0] = RPC_AUTH_NULL;
> > +		*info->auth_flav_len = 1;
> > +	}
> > out:
> > 	return status;
> > 
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index a0949f5..ceb60c7 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -1620,19 +1620,6 @@ static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
> > 	rpc_authflavor_t flavor;
> > 
> > 	/*
> > -	 * The NFSv2 MNT operation does not return a flavor list.
> > -	 */
> > -	if (args->mount_server.version != NFS_MNT3_VERSION)
> > -		goto out_default;
> > -
> > -	/*
> > -	 * Certain releases of Linux's mountd return an empty
> > -	 * flavor list in some cases.
> > -	 */
> > -	if (count == 0)
> > -		goto out_default;
> > -
> > -	/*
> > 	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
> > 	 * must be in the list returned by the server.
> > 	 *
> > -- 
> > 1.8.1.4
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Jeff Layton <jlayton@redhat.com>
