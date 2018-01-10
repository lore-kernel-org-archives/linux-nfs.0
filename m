Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39056 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965876AbeAJRRF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 Jan 2018 12:17:05 -0500
Date: Wed, 10 Jan 2018 12:17:04 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Steve Dickson <SteveD@RedHat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 0/3] Add server-side support for junctions to
 nfs-utils
Message-ID: <20180110171704.GB26882@fieldses.org>
References: <20180108213356.20133.54161.stgit@manet.1015granger.net>
 <20180109192100.GB18087@fieldses.org>
 <492B1883-83EE-40AF-AA8C-1B797D842E5E@oracle.com>
 <01acd06d-98d4-c6ff-5ef1-b6edbb447405@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <01acd06d-98d4-c6ff-5ef1-b6edbb447405@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 10, 2018 at 12:13:39PM -0500, Steve Dickson wrote:
> 
> 
> On 01/09/2018 02:36 PM, Chuck Lever wrote:
> > 
> > 
> >> On Jan 9, 2018, at 2:21 PM, bfields@fieldses.org wrote:
> >>
> >> Thanks for doing this!  I may not get the chance to do a real review,
> >> but I'm in favor of the basic idea.
> > 
> > How do you feel about building support for junctions into mountd,
> > and getting rid of the libnfsjunct DLL ?
> I would rather not put new functionality in daemons that needs rpcbind.
> With the idea of, someday, having clean v4-only configuration
> (aka no mountd, statd, or lockd).  

rpc.mountd is used by v4 for a lot of stuff already, so it's not going
away.  Is it trying to register with rpcbind in the case it's called
with -N2 -N3?  That would be a bug.

--b.
