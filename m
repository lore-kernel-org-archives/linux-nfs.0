Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:55850 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730419AbeHISMa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Aug 2018 14:12:30 -0400
Date: Thu, 9 Aug 2018 11:46:58 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: ensure that writing '+4' to /proc/fs/nfsd/versions
 enables minor version 0
Message-ID: <20180809154658.GJ18747@coeurl.usersys.redhat.com>
References: <20180808113600.11502-1-smayhew@redhat.com>
 <0ad3edde2c778dc0477c314b94c194b8365e2ee9.camel@hammerspace.com>
 <20180808130732.GI18747@coeurl.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180808130732.GI18747@coeurl.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 08 Aug 2018, Scott Mayhew wrote:

> On Wed, 08 Aug 2018, Trond Myklebust wrote:
> 
> > On Wed, 2018-08-08 at 07:36 -0400, Scott Mayhew wrote:
> > > According to commit d3635ff07e8 ("nfsd: fix configuration of
> > > supported
> > > minor versions"), it should be possible to use either '4.0' or '4' to
> > > enable or disable minor version 0.
> > > 
> > > Currently, writing '+4' to /proc/fs/nfsd/versions has no effect
> > > unless
> > > no minor versions are enabled.  That leaves rpc.nfsd without an easy
> > > way to re-enable v4.0, since that's what it does when invoked with
> > > '-V 4.0'.
> > > 
> > > Fixes: d3635ff07e8 ("nfsd: fix configuration of supported minor
> > > versions")
> > > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > > ---
> > >  fs/nfsd/nfsctl.c | 8 ++++++++
> > >  1 file changed, 8 insertions(+)
> > > 
> > > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > > index d107b4426f7e..b3f9f9233953 100644
> > > --- a/fs/nfsd/nfsctl.c
> > > +++ b/fs/nfsd/nfsctl.c
> > > @@ -614,6 +614,14 @@ static ssize_t __write_versions(struct file
> > > *file, char *buf, size_t size)
> > >  					minor = 0;
> > >  					while (nfsd_minorversion(minor,
> > > cmd) >= 0)
> > >  						minor++;
> > > +				} else if (cmd == NFSD_SET) {
> > > +					/*
> > > +					 * We have +4 but there are
> > > already some minors
> > > +					 * enabled.  We must ensure 4.0
> > > gets enabled,
> > > +					 * since it could be a request
> > > from rpc.nfsd.
> > > +					 */
> > > +					if (nfsd_minorversion(0, cmd) <
> > > 0)
> > > +						return -EINVAL;
> > >  				}
> > >  				break;
> > >  			default:
> > 
> > This breaks the intention behind that patch, which was to ensure that
> > +4 must _not_ automatically enable 4.0...
> > 
> > Instead, you use +/-4.0 to enable/disable 4.0, just like you use +/-4.1 
> > to enable/disable 4.1, +/-4.2 to enable/disable 4.2, etc, etc...
> > 
> > The special value +/-4 exists in order allow you to disable/enable v4
> > altogether. i.e. '-4' acts as a mask to turn off v4.x for all values of
> > x. '+4' will enable v4.x for those values of x which have been
> > explicitly set.
> 
> Okay I guess I'm confused by this wording from the commit message in
> d3635ff07e8:
> 
>     Allow the user to use either '4.0' or '4' to enable or disable minor
>     version 0.  Other minor versions are still enabled or disabled using the
>     '4.x' format.

Okay I see that that commit message actually came from Bruce and is
different than the original commit message... but in your original cover
letter (https://marc.info/?l=linux-nfs&m=148780658904187&w=2) you stated
that '+4' should enable 4.0:

"""
2) Allow the user to use either '4.0' or '4' in order to enable or disable
   minor version 0. Other minor versions remain enabled/disabled using the
   '4.x' format.
"""

I thought the point of your patches were to allow the user to enable 4.x
(for x > 0) without enabling 4.0.  My patch doesn't change that.  All it
does is allow '+4' to enable 4.0, which is what both Bruce's commit
message and your cover letter says it should do.

current HEAD:

[root@fedora27_1236568e ~]# echo '-4' >/proc/fs/nfsd/versions
[root@fedora27_1236568e ~]# cat /proc/fs/nfsd/versions
-2 +3 -4 -4.0 -4.1 -4.2
[root@fedora27_1236568e ~]# echo '+4.1' >/proc/fs/nfsd/versions
[root@fedora27_1236568e ~]# !cat
cat /proc/fs/nfsd/versions
-2 +3 +4 -4.0 +4.1 -4.2
[root@fedora27_1236568e ~]# echo '+4' >/proc/fs/nfsd/versions
[root@fedora27_1236568e ~]# !cat
cat /proc/fs/nfsd/versions
-2 +3 +4 -4.0 +4.1 -4.2

with my patch:

[root@fedora27_8686dfcb ~]# echo '-4' >/proc/fs/nfsd/versions 
[root@fedora27_8686dfcb ~]# cat /proc/fs/nfsd/versions 
-2 +3 -4 -4.0 -4.1 -4.2
[root@fedora27_8686dfcb ~]# echo '+4.1' >/proc/fs/nfsd/versions
[root@fedora27_8686dfcb ~]# !cat
cat /proc/fs/nfsd/versions 
-2 +3 +4 -4.0 +4.1 -4.2 <----- 4.0 is still disabled
[root@fedora27_8686dfcb ~]# echo '+4' >/proc/fs/nfsd/versions 
[root@fedora27_8686dfcb ~]# !cat
cat /proc/fs/nfsd/versions 
-2 +3 +4 +4.1 -4.2 <----- 4.0 is enabled

-Scott

> 
> Should rpc.nfsd be changed then?  The way it is now, nfssvc_print_vers() will
> write '+4' if you run 'rpc.nfsd -V4.0'...
> 
> > 
> > -- 
> > Trond Myklebust
> > CTO, Hammerspace Inc
> > 4300 El Camino Real, Suite 105
> > Los Altos, CA 94022
> > www.hammer.space
> > 
> > 
