Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37422 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1948042AbcBRUjR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Feb 2016 15:39:17 -0500
Date: Thu, 18 Feb 2016 15:39:15 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Martin Houry <martinhoury@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1
 Session Trunking"
Message-ID: <20160218203915.GA7771@fieldses.org>
References: <CAEUt8V+L3hV1tQTzanVjGyZ1qoG8qJk7ZnS5HM1_3+Nc4mpO3A@mail.gmail.com>
 <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com>
 <B10307D6-13C6-4A04-B3A9-B66C27F51E19@oracle.com>
 <20160217205929.GF10401@fieldses.org>
 <3B48A59F-638A-45C9-B2E4-2D65C00DE639@netapp.com>
 <B748F703-4298-4D1D-BACB-13B0560E5901@oracle.com>
 <CAHQdGtRO8e7LF_2E9hcSV90CsbbfkboX9VOUSiuQWRBs_EBGLA@mail.gmail.com>
 <20160218141447.GB4256@fieldses.org>
 <CAHQdGtRt-iuY-R3xQQyiXni=HD8DKzYX7pkaN=8xCuAWBeyOiw@mail.gmail.com>
 <839836DE-11FD-4310-A76E-630548C0777B@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <839836DE-11FD-4310-A76E-630548C0777B@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 18, 2016 at 07:41:19PM +0000, Adamson, Andy wrote:
> 
> > On Feb 18, 2016, at 1:32 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> > On Thu, Feb 18, 2016 at 9:14 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> 
> >> On Wed, Feb 17, 2016 at 06:55:43PM -0500, Trond Myklebust wrote:
> >>> On Wed, Feb 17, 2016 at 5:52 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >>>> 
> >>>>> On Feb 17, 2016, at 5:35 PM, Adamson, Andy <William.Adamson@netapp.com> wrote:
> >>>>> The fs_locations would need to be requested by the client. I guess we reqest them at every mountâ€Ķ.
> >>>> 
> >>>> Yep, and fetch them again every so often. There's no real
> >>>> cache coherency protocol for this information. (That's
> >>>> where a pNFS layout might be more valuable).
> >>> 
> >>> If your goal is to do session trunking, you only really need to check
> >>> the fs_locations attribute on the root file system. (so
> >>> GETROOTFH+GETATTR(fs_locations)). That's the natural place for a
> >>> server to advertise its full set of IP addresses, and the session
> >>> trunking protocol itself will allow you to winnow out any that might
> >>> belong to a replica server.
> >> 
> >> I worry that round-robin could behave really badly if the client's path
> >> to the two IP addresses have different performance characteristics.  But
> >> a server should probably still be allowed to advertise those as replicas
> >> (e.g.  maybe a slower interface is usable as a fallback?).
> >> 
> >> So maybe we should be careful about making this automatic.  Unless the
> >> load-balancing is a little smarter than pure round robin.  Or unless we
> >> can get some more fine-grained information (maybe someone could use
> >> fs_location_info's preference information for this?).
> > 
> > The multipath policy is pluggable. If you need something more clever
> > than round robin, then feel free to play. However do note that for
> > pNFS multipathing, both the files and flexfiles specs are clear that
> > you should not mix slow and fast transports. I imagine you probably
> > want to do the same for fs_locations.
> > 
> > As for fs_locations_info, please see FSLI4BX_(READ|WRITE)(RANK|ORDER).
> 
> OK. I’m testing session trunking using new multiple hostname mount options. I’ll submit another RFC patchset.
> Then, caveat patchset response, I’ll switch from the multiple hostname mount options to fs_locations_info

You mean you want to remove support for the commandline list of
hostnames at that point?

I'd rather keep support for listing them on the commandline.  I think
the fs_locations_info is a little more complicated than I did at first
look.  (Among other things, it requires server support, and some thought
about how exactly to interpret that fs_locations_info preference
information.)

--b.
