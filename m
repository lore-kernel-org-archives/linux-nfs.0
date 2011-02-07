Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755146Ab1BGWAd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Feb 2011 17:00:33 -0500
Date: Mon, 7 Feb 2011 17:00:24 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: Bryan Schumaker <bjschuma@netapp.com>, Benny Halevy <bhalevy@panasas.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Thomas Haynes <thomas@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: Patched up cthon source?
Message-ID: <20110207170024.1d558d5f@tlielax.poochiereds.net>
In-Reply-To: <20110207191321.GB4036@merit.edu>
References: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com>
	<83EC814B-1043-46B2-8F5E-E1FB1F5B56BF@oracle.com>
	<4D3DFE40.1070605@panasas.com>
	<4D3ED37D.6020606@netapp.com>
	<20110125095649.446212fd@tlielax.poochiereds.net>
	<20110207191321.GB4036@merit.edu>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 7 Feb 2011 14:13:21 -0500
Jim Rees <rees@umich.edu> wrote:

> Jeff Layton wrote:
> 
>   On Tue, 25 Jan 2011 08:43:25 -0500
>   Bryan Schumaker <bjschuma@netapp.com> wrote:
>   
>   > On 01/24/2011 05:33 PM, Benny Halevy wrote:
>   > > this is a problem with the version of nroff on newer distributions.
>   > 
>   > My version of groff (1.21) is splitting the error into two lines, so I am using the following patch.
>   > 
>   > Bryan
>   > 
>   
>   Yep, this workaround stopped working around for me on my rawhide box
>   broke yesterday for the same reason.
>   
>   I think this patch may be a better approach than trying to grep out
>   random stuff, but I don't know whether non-GNU tbl programs will barf
>   on it. If anyone has a solaris box handy, could you let me know if
>   this breaks on it?
> 
> Your patch does not work for me on Ubuntu with groff 1.20.1.

Ahh yeah, looks like "nowarn" is a very new option. All the more reason
for Steve to drop that patch. He had some other patches to the code that
should make it superfluous anyway.

-- 
Jeff Layton <jlayton@redhat.com>
