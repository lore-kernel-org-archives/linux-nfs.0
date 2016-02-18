Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36988 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425429AbcBROOs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Feb 2016 09:14:48 -0500
Date: Thu, 18 Feb 2016 09:14:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Martin Houry <martinhoury@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1
 Session Trunking"
Message-ID: <20160218141447.GB4256@fieldses.org>
References: <CAEUt8V+L3hV1tQTzanVjGyZ1qoG8qJk7ZnS5HM1_3+Nc4mpO3A@mail.gmail.com>
 <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com>
 <B10307D6-13C6-4A04-B3A9-B66C27F51E19@oracle.com>
 <20160217205929.GF10401@fieldses.org>
 <3B48A59F-638A-45C9-B2E4-2D65C00DE639@netapp.com>
 <B748F703-4298-4D1D-BACB-13B0560E5901@oracle.com>
 <CAHQdGtRO8e7LF_2E9hcSV90CsbbfkboX9VOUSiuQWRBs_EBGLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHQdGtRO8e7LF_2E9hcSV90CsbbfkboX9VOUSiuQWRBs_EBGLA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 17, 2016 at 06:55:43PM -0500, Trond Myklebust wrote:
> On Wed, Feb 17, 2016 at 5:52 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >
> >> On Feb 17, 2016, at 5:35 PM, Adamson, Andy <William.Adamson@netapp.com> wrote:
> >> The fs_locations would need to be requested by the client. I guess we reqest them at every mountâ€Ķ.
> >
> > Yep, and fetch them again every so often. There's no real
> > cache coherency protocol for this information. (That's
> > where a pNFS layout might be more valuable).
> 
> If your goal is to do session trunking, you only really need to check
> the fs_locations attribute on the root file system. (so
> GETROOTFH+GETATTR(fs_locations)). That's the natural place for a
> server to advertise its full set of IP addresses, and the session
> trunking protocol itself will allow you to winnow out any that might
> belong to a replica server.

I worry that round-robin could behave really badly if the client's path
to the two IP addresses have different performance characteristics.  But
a server should probably still be allowed to advertise those as replicas
(e.g.  maybe a slower interface is usable as a fallback?).

So maybe we should be careful about making this automatic.  Unless the
load-balancing is a little smarter than pure round robin.  Or unless we
can get some more fine-grained information (maybe someone could use
fs_location_info's preference information for this?).

--b.

> 
> You might want to refresh that info whenever the connection goes away
> on one or more addresses without a reboot so you can detect when NICs
> are going away.
> 
> Otherwise, polling every couple of hours or so for new NICs shouldn't
> be too burdensome...
> 
> Cheers,
>  Trond
