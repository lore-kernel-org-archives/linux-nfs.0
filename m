Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbaKFOqZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Nov 2014 09:46:25 -0500
Date: Thu, 6 Nov 2014 09:46:22 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [nfs-utils RFC PATCH 11/15] mountstats: Allow mountstats_command
 to take a variable number of mountpoints
Message-ID: <20141106144622.GL4532@tonberry.usersys.redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
 <1415206872-864-12-git-send-email-smayhew@redhat.com>
 <52AAA463-33E9-4112-B000-51CDFD1A53F8@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52AAA463-33E9-4112-B000-51CDFD1A53F8@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 05 Nov 2014, Chuck Lever wrote:

> 
> On Nov 5, 2014, at 12:01 PM, Scott Mayhew <smayhew@redhat.com> wrote:
> 
> > Allow the mountstats command to take a variable number of mountpoints
> > (including none, in which case it will print stats for all NFS
> > mountpoints it finds).
> 
> Cool idea.

Thanks!  It looks like I need to add some sort of a header when only the
rpc stats are being printed though.

> 
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> > ---
> > tools/mountstats/mountstats.py | 32 +++++++++++++++++++-------------
> > 1 file changed, 19 insertions(+), 13 deletions(-)
> > 
> > diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> > index 77975ad..281f4be 100755
> > --- a/tools/mountstats/mountstats.py
> > +++ b/tools/mountstats/mountstats.py
> > @@ -616,10 +616,6 @@ def mountstats_command():
> >             assert False, "unhandled option"
> >     mountpoints += args
> > 
> > -    if mountpoints == []:
> > -        print_mountstats_help(prog)
> > -        return
> > -
> >     if rpc_only == True and nfs_only == True:
> >         print_mountstats_help(prog)
> >         return
> > @@ -628,21 +624,31 @@ def mountstats_command():
> >         infile = '/proc/self/mountstats'
> >     mountstats = parse_stats_file(infile)
> > 
> > +    # make certain devices contains only NFS mount points
> > +    if len(mountpoints) > 0:
> > +        check = []
> > +        for device in mountpoints:
> > +            stats = DeviceData()
> > +            stats.parse_stats(mountstats[device])
> > +            if stats.is_nfs_mountpoint():
> > +                check += [device]
> > +        mountpoints = check
> > +    else:
> > +        for device, descr in mountstats.items():
> > +            stats = DeviceData()
> > +            stats.parse_stats(descr)
> > +            if stats.is_nfs_mountpoint():
> > +                mountpoints += [device]
> > +    if len(mountpoints) == 0:
> > +        print('No NFS mount points were found')
> > +        return
> > +
> >     if since:
> >         old_mountstats = parse_stats_file(since)
> > 
> >     for mp in mountpoints:
> > -        if mp not in mountstats:
> > -            print('Statistics for mount point %s not found' % mp)
> > -            continue
> > -
> >         stats = DeviceData()
> >         stats.parse_stats(mountstats[mp])
> > -
> > -        if not stats.is_nfs_mountpoint():
> > -            print('Mount point %s exists but is not an NFS mount' % mp)
> > -            continue
> > -
> >         if not since:
> >             print_mountstats(stats, nfs_only, rpc_only)
> >         elif since and mp not in old_mountstats:
> > -- 
> > 1.9.3
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
