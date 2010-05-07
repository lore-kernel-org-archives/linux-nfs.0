From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils] Allow mountd to not listen for RPC calls when
 v2/v3 disabled
Date: Fri, 7 May 2010 13:37:44 +0200
Message-ID: <20100507133744.4baabfff@corrin.poochiereds.net>
References: <20100506171144.4d7bec37@notabene.brown>
	<4BE2E600.504@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754097Ab0EGLhy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 May 2010 07:37:54 -0400
In-Reply-To: <4BE2E600.504@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 06 May 2010 11:53:36 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi Neil-
> 
> On 05/06/2010 03:11 AM, Neil Brown wrote:
> >
> > Mountd listens on 2 different versions for NFSv2 (MOUNTv1 and MOUNTv2)
> > and one for NFSv3 (MOUNTv3)
> >
> > When --no-nfs-version requests an NFS version to be disabled, the
> > code actually disabled the MOUNT version. This works is several cases,
> > but requires --no-nfs-version 1 to completely disable NFSv2, which
> > is wrong.
> >
> > So if we do disable 1, 2, and 3. mountd complain and won't run, it
> > is not possible to run just v4 - i.e. not listening for MOUNT requests
> > at all (as v4 doesn't need them).
> >
> > So change the handling of "--no-nfs-version 2" it disable MOUNTv1 as well as
> > MOUNTv2, and allow mountd to continue running as long as one of
> > NFSv2 NFSv3 NFSv4 is enabled.
> >
> > Signed-off-by: NeilBrown<neilb@suse.de>
> >
> > diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> > index a0a1f2d..5373d81 100644
> > --- a/utils/mountd/mountd.c
> > +++ b/utils/mountd/mountd.c
> > @@ -80,10 +80,10 @@ static int nfs_version = -1;
> >   static void
> >   unregister_services (void)
> >   {
> > -	if (nfs_version&  0x1)
> > +	if (nfs_version&  (0x1<<  1)) {
> >   		pmap_unset (MOUNTPROG, MOUNTVERS);
> > -	if (nfs_version&  (0x1<<  1))
> >   		pmap_unset (MOUNTPROG, MOUNTVERS_POSIX);
> > +	}
> >   	if (nfs_version&  (0x1<<  2))
> >   		pmap_unset (MOUNTPROG, MOUNTVERS_NFSV3);
> >   }
> > @@ -712,8 +712,10 @@ main(int argc, char **argv)
> >   			usage(argv [0], 1);
> >   		}
> >
> > -	/* No more arguments allowed. */
> > -	if (optind != argc || !(nfs_version&  0x7))
> > +	/* No more arguments allowed.
> > +	 * Require at least one valid version (2, 3, or 4)
> > +	 */
> > +	if (optind != argc || !(nfs_version&  0xE))
> 
> IMO macros would be a little more explanatory than constant expressions 
> like "0xE" and "0x1 << 2".
> 
> >   		usage(argv [0], 1);
> >
> >   	if (chdir(state_dir)) {
> > @@ -761,12 +763,12 @@ main(int argc, char **argv)
> >   	if (new_cache)
> >   		cache_open();
> >
> > -	if (nfs_version&  0x1)
> > +	if (nfs_version&  (0x1<<  1)) {
> 
> Jeff and I talked recently about disabling mountd's RPC listeners if 
> only NFSv4 was desired.  I can't remember the details, but this is 
> roughly what we thought was appropriate.  Jeff, was there another issue 
> I'm not remembering?
> 

Seems like we had some question of whether svc_run would work correctly
without any listeners. I thought that we had determined that it
*would* though, so I think Neil's patch should be fine.

> >   		rpc_init("mountd", MOUNTPROG, MOUNTVERS,
> >   			 mount_dispatch, port);
> > -	if (nfs_version&  (0x1<<  1))
> >   		rpc_init("mountd", MOUNTPROG, MOUNTVERS_POSIX,
> >   			 mount_dispatch, port);
> > +	}
> >   	if (nfs_version&  (0x1<<  2))
> >   		rpc_init("mountd", MOUNTPROG, MOUNTVERS_NFSV3,
> >   			 mount_dispatch, port);
> 


-- 
Jeff Layton <jlayton@redhat.com>
