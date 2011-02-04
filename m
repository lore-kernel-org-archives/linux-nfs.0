Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50865 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676Ab1BDEVc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 23:21:32 -0500
Subject: Re: [PATCH] Ensure user-supplied string null terminated before
 kstrdup()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Rob Landley <rlandley@parallels.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4D4B76F8.8060500@parallels.com>
References: <4D4B287E.70206@parallels.com>
	 <1296788385.2957.8.camel@heimdal.trondhjem.org>
	 <4D4B76F8.8060500@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Feb 2011 23:21:30 -0500
Message-ID: <1296793290.3911.19.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-03 at 21:48 -0600, Rob Landley wrote: 
> On 02/03/2011 08:59 PM, Trond Myklebust wrote:
> > On Thu, 2011-02-03 at 16:13 -0600, Rob Landley wrote: 
> >> From: Rob Landley <rlandley@parallels.com>
> >>
> >> Make sure user string is null terminated before copying it.
> >>
> >> Signed-off-by: Rob Landley <rlandley@parallels.com>
> >> ---
> >>
> >>  fs/nfs/super.c |    5 ++++-
> >>  1 file changed, 4 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> >> index b68c860..0ad1255 100644
> >> --- a/fs/nfs/super.c
> >> +++ b/fs/nfs/super.c
> >> @@ -1881,9 +1881,12 @@ static int nfs_validate_mount_data(void *options,
> >>  
> >>  		if (!(data->flags & NFS_MOUNT_TCP))
> >>  			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
> >> +		/* Force null termination of data->hostname no matter what
> >> +		   user passed in. */
> >> +		args->namlen		= data->namlen;
> >> +		data->namlen = 0;
> >>  		/* N.B. caller will free nfs_server.hostname in all cases */
> >>  		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
> >> -		args->namlen		= data->namlen;
> >>  		args->bsize		= data->bsize;
> >>  
> >>  		if (data->flags & NFS_MOUNT_SECFLAVOUR)
> > 
> > The "namlen" mount option bears absolutely no relation to the server
> > hostname AFAIK. I can't see how this patch makes sense...
> 
> That field is right after the hostname in the struct, therefore if it's
> zeroed the data->hostname is guaranteed to be null terminated at the end
> of its nominal range.  (A bit subtle, hence the comment.)

No. Changing a user specified mount option in order to zero the previous
field is completely unacceptable....

> This isn't necessarily the proper fix, but I don't see why the user
> can't feed in a "data" blob with an arbitrarily long hostname.  This is
> user supplied data we're arbitrarily kstrdup()ing without checking it,
> right?  (Is there a size limit on the option string?  Does the range
> check on userspace pointers prevent it from being right _before_
> something we shouldn't read and padding up to it?)

The right thing to do, is to check the value of strlen(data->hostname)
and to return -EINVAL if it exceeds (sizeof(data->hostname) - 1).

This is a (legacy) _binary_  interface for mounts. Adjusting the value
of the next field in the structure is never going to prevent an attack
that relies on an overflow condition. What about the values of the
nfs_mount_data's root filehandle or the security context fields? If they
have been screwed up due to an overflow attack on the hostname field,
then you are still compromised...

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

