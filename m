Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51180 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751348AbdISUmY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Sep 2017 16:42:24 -0400
Date: Tue, 19 Sep 2017 16:42:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Daniel P. Berrange" <berrange@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
Message-ID: <20170919204224.GA14329@fieldses.org>
References: <DE7FAAE5-26F5-4B11-A83D-F74C9B7D81FB@oracle.com>
 <20170915164223.GE23557@fieldses.org>
 <A1844833-18E1-4F03-BB20-A06A6FE4AB62@oracle.com>
 <20170918180927.GD12759@stefanha-x1.localdomain>
 <20170919093140.GF9536@redhat.com>
 <67608054-B771-44F4-8B2F-5F7FDC506CDD@oracle.com>
 <20170919151051.GS9536@redhat.com>
 <3534278B-FC7B-4AA5-AF86-92AA19BFD1DC@oracle.com>
 <20170919164427.GV9536@redhat.com>
 <E94E2759-1734-4C52-838F-8906B3F969C0@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E94E2759-1734-4C52-838F-8906B3F969C0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 19, 2017 at 03:56:50PM -0400, Chuck Lever wrote:
> A proof of concept is nice, but it isn't sufficient for merging
> NFS/VSOCK into upstream Linux. Unlike Ceph, NFS is an Internet
> standard. We can't introduce changes as we please and expect
> the rest of the world to follow us.
> 
> I know the Ganesha folks chafe at this requirement, because
> standardization progress can sometimes be measured in geological
> time units.

It doesn't need to be--I think we're only asking for a few pages here,
and nothing especially complicated (at the protocol level).  That
shouldn't take so long.  (Not to be published as an RFC, necessarily,
but to get far enough along that we can be pretty certain it won't need
incompatible changes.)

--b.
