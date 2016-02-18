Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36978 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425304AbcBROF0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Feb 2016 09:05:26 -0500
Date: Thu, 18 Feb 2016 09:05:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        Martin Houry <martinhoury@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1
 Session Trunking"
Message-ID: <20160218140524.GA4256@fieldses.org>
References: <CAEUt8V+L3hV1tQTzanVjGyZ1qoG8qJk7ZnS5HM1_3+Nc4mpO3A@mail.gmail.com>
 <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com>
 <B10307D6-13C6-4A04-B3A9-B66C27F51E19@oracle.com>
 <20160217205929.GF10401@fieldses.org>
 <3B48A59F-638A-45C9-B2E4-2D65C00DE639@netapp.com>
 <B748F703-4298-4D1D-BACB-13B0560E5901@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <B748F703-4298-4D1D-BACB-13B0560E5901@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 17, 2016 at 05:52:03PM -0500, Chuck Lever wrote:
> 
> > On Feb 17, 2016, at 5:35 PM, Adamson, Andy <William.Adamson@netapp.com> wrote:
> > 
> > 
> >> On Feb 17, 2016, at 3:59 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> 
> >> On Wed, Feb 17, 2016 at 02:06:35PM -0500, Chuck Lever wrote:
> >>> 
> >>>> On Feb 17, 2016, at 9:50 AM, Adamson, Andy
> >>>> <William.Adamson@netapp.com> wrote: Thanks for testing. As Trond
> >>>> pointed out, the correct way to indicate multiple hostnames is on
> >>>> the mount command line
> >>>> 
> >>>> mount -o minorversion=1 host1,host2,ÃĒâŽÂĶ,hostn:/<export>  /<mntdir>
> >>> 
> >>> It might be more natural for NFSv4.x to use a referral or a pNFS
> >>> layout instead.  Do you think that's a viable approach?
> >> 
> >> Seems like an easy application for fs_locations{_info?}.  It'd need
> >> server support too, and I think you probably want this manual method as
> >> well for now.
> > 
> > I agree that the manual method is useful as it allows the client admin to decide if the mount requires session trunking.
> 
> Seems like the server admin is in a better position to know
> the locations of replicated data. The server can advertise
> the most up-to-date location information. More scalable
> than telling every client admin how to set this up.
> 
> Adding this CLI to mount means it will be around a long time,
> so we'd better be sure we want to support it for that long.
> (Yes, I know, who is this "we").
> 
> 
> > The fs_locations would need to be requested by the client. I guess we reqest them at every mountâĶ.
> 
> Yep, and fetch them again every so often. There's no real
> cache coherency protocol for this information. (That's
> where a pNFS layout might be more valuable).
> 
> The Linux server should be able to advertise replicas using
> the replicas= export option.

Right, but for the simple case of a server with multiple interfaces but
no other replicas it might be nice if the server could generate the
fs_locations info on its own (an explicit replicas= could still override
that).

But I don't know if it's possible to reliably enumerate the right set of
IP addresses.  Some interfaces may not be on the right network, etc.

Or interfaces might have different performance characteristics, in which
case round-robin wouldn't be a good idea.  So I guess this shouldn't be
automatic unless we want to put in way more smarts.

--b.
