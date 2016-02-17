Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33100 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965013AbcBQU7a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Feb 2016 15:59:30 -0500
Date: Wed, 17 Feb 2016 15:59:29 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        Martin Houry <martinhoury@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1
 Session Trunking"
Message-ID: <20160217205929.GF10401@fieldses.org>
References: <CAEUt8V+L3hV1tQTzanVjGyZ1qoG8qJk7ZnS5HM1_3+Nc4mpO3A@mail.gmail.com>
 <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com>
 <B10307D6-13C6-4A04-B3A9-B66C27F51E19@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <B10307D6-13C6-4A04-B3A9-B66C27F51E19@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 17, 2016 at 02:06:35PM -0500, Chuck Lever wrote:
> 
> > On Feb 17, 2016, at 9:50 AM, Adamson, Andy
> > <William.Adamson@netapp.com> wrote: Thanks for testing. As Trond
> > pointed out, the correct way to indicate multiple hostnames is on
> > the mount command line
> > 
> > mount -o minorversion=1 host1,host2,â€¦,hostn:/<export>  /<mntdir>
> 
> It might be more natural for NFSv4.x to use a referral or a pNFS
> layout instead.  Do you think that's a viable approach?

Seems like an easy application for fs_locations{_info?}.  It'd need
server support too, and I think you probably want this manual method as
well for now.

I wonder if the server can easily generate a list of IP addresses to
advertise automatically?  In which case the whole thing would be
zero-configuration, which would be nice.

pNFS sounds like overkill.

--b.
