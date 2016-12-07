Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60346 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752441AbcLGSIs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 13:08:48 -0500
Date: Wed, 7 Dec 2016 13:08:43 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
Message-ID: <20161207180843.GA20626@parsley.fieldses.org>
References: <148065078775.28046.5506130555300891075.stgit@noble>
 <148065110833.28046.2561331715736018574.stgit@noble>
 <8e72acac-42de-bf02-9069-60e7b6a12c04@RedHat.com>
 <87r35k4rcr.fsf@notabene.neil.brown.name>
 <35ca5ad2-39db-a46b-13b2-a2e5128793a0@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <35ca5ad2-39db-a46b-13b2-a2e5128793a0@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 07, 2016 at 09:44:25AM -0500, Steve Dickson wrote:
> 
> 
> On 12/06/2016 05:36 PM, NeilBrown wrote:
> > On Wed, Dec 07 2016, Steve Dickson wrote:
> > 
> >>> +.B nfsd
> >>> +Recognized values:
> >>> +.BR threads ,
> >>> +.BR grace-time ,
> >>> +.BR lease-time ,
> >>> +.BR udp ,
> >>> +.BR tcp ,
> >>> +.BR vers2 ,
> >>> +.BR vers3 ,
> >>> +.BR vers4 ,
> >>> +.BR vers4.0 ,
> >> Do we need both ver4 and ver4.0?
> > 
> > "vers4" allows you to enable or disable v4 has a whole.
> > The assumption is that if enabled, all minor versions that the kernel
> > supports will be enabled by default.
> > vers4.x allows individual minor versions to be disabled, so
> >  vers4=yes
> >  vers4.0=no
> > would disable v4.0, just like "-V4 -N4.0"
> I see...
> 
> > 
> > I do wonder if this is ever valid though.  Why do we allow minor
> > versions to be enabled/disabled?
> IDK... I think Trond did this... you know...
> when in doubt... blame Trond! 8-) 

Or Benny, 8daf220a6a83 "nfsd41: control nfsv4.1 svc via
/proc/fs/nfsd/versions".

> > Does it make any sense to enable a non-contiguous set of minor versions?
> I don't think so... Talk about handing people rope! ;-)

I can't think of a reason either.

> > Should we just have a maximum NFSv4 minor version?
> Maybe.. 

If you do that then I'd allow a minimum too.

--b.

> > I was trying to duplicate the current functionality as closely as
> > convenient.  That might not be best in this case.
> You did a good job... this is definitely a nit.
> 
> steved.
> 
