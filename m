Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38550 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424800AbcBSPBh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Feb 2016 10:01:37 -0500
Date: Fri, 19 Feb 2016 10:01:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Martin Houry <martinhoury@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1
 Session Trunking"
Message-ID: <20160219150135.GD17042@fieldses.org>
References: <B10307D6-13C6-4A04-B3A9-B66C27F51E19@oracle.com>
 <20160217205929.GF10401@fieldses.org>
 <3B48A59F-638A-45C9-B2E4-2D65C00DE639@netapp.com>
 <B748F703-4298-4D1D-BACB-13B0560E5901@oracle.com>
 <CAHQdGtRO8e7LF_2E9hcSV90CsbbfkboX9VOUSiuQWRBs_EBGLA@mail.gmail.com>
 <20160218141447.GB4256@fieldses.org>
 <CAHQdGtRt-iuY-R3xQQyiXni=HD8DKzYX7pkaN=8xCuAWBeyOiw@mail.gmail.com>
 <839836DE-11FD-4310-A76E-630548C0777B@netapp.com>
 <20160218203915.GA7771@fieldses.org>
 <336DFCFA-5655-4CB1-82F2-9E3B17030094@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <336DFCFA-5655-4CB1-82F2-9E3B17030094@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 18, 2016 at 04:29:46PM -0500, Chuck Lever wrote:
> True; there's a reason I never got to implementing
> fs_locations_info on the Linux server for FedFS. There
> are sticky problems around the mountd upcall that is
> used to communicate this information to the kernel,
> for example.
> 
> However, I don't agree that this is a good reason to
> go with multiple hostnames on the mount command line.
> I like Andy's plan to keep this CLI change out of the
> long term upstream code, but continue to use it for
> testing.

Even if we get an fs_locations_info-based solution to the point where
it's the best default, don't you think we'll still want some kind of
manual override on the client?

The decision here has to do with the path between client and server,
and the server may not always be in the best position to make that
decision.

--b.
