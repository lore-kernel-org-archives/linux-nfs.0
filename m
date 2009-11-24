From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Tue, 24 Nov 2009 15:56:16 -0500
Message-ID: <20091124205616.GB29856@fieldses.org>
References: <19211.7054.291514.185591@notabene.brown> <4B0BEDDB.1010203@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39267 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932646AbZKXUzd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 15:55:33 -0500
In-Reply-To: <4B0BEDDB.1010203-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2009 at 09:29:47AM -0500, Steve Dickson wrote:
> 
> 
> On 11/23/2009 06:32 PM, Neil Brown wrote:
> > 
> > Hi,
> >  I recently packaged nfs-utils 1.2.1 for openSUSE and fairly quickly
> >  got a bug report - "-o nfsvers=3" was needed to mount NFSv3
> >  filesystems.
> > 
> >  mount.nfs in 1.2.1 will first try a v4 mount but will fall-back to v3
> >  if it gets ENOENT.  This works fine.
> >  However for kernel prior to 2.6.25, you don't get ENOENT, you get
> >  EPERM.
> >  In that case the fall-back to v3 doesn't happen and you get a failure
> >  to mount.
> > 
> >  So I think we need to fall back on EPERM as well.  See below.
> I already posted this patch on the v4 mailing list
> http://linux-nfs.org/pipermail/nfsv4/2009-November/011595.html
> but it got shot down...  at least that's how I interpreted the
> responses... 
> 
> But I do thing we need this, since there are so many server 
> that will simple break if we don't... Agreed?

My position is that servers should either a) turn off NFSv4 or b) add a
pseudoroot, and that we should modify initscripts to make this harder to
screw up.

(For now (without automatic pseudoroot creation) we should by default be
running rpc.nfsd with -N 4; and adding the v4 support should be
something administrators do when they add a pseudoroot.)

((If this is really totally unfeasible, then I should quickly cue up a
revert for the patch I have queued for 2.6.33 which changes this error
again, to SERVERFAULT....))

--b.

> 
> steved. 
> 
> 
> > 
> > Thanks,
> > NeilBrown
> > 
> > 
> > diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> > index b595649..68eb82b 100644
> > --- a/utils/mount/stropts.c
> > +++ b/utils/mount/stropts.c
> > @@ -657,8 +657,10 @@ static int nfs_try_mount(struct nfsmount_info *mi)
> >  				 * To deal with legacy Linux servers that don't
> >  				 * automatically export a pseudo root, retry
> >  				 * ENOENT errors using version 3
> > +				 * And for Linux servers prior to 2.6.25, retry
> > +				 * EPERM
> >  				 */
> > -				if (errno != ENOENT)
> > +				if (errno != ENOENT && errno != EPERM)
> >  					break;
> >  			}
> >  		}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
