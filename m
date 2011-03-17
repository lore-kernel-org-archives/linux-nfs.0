Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756714Ab1CQBVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 21:21:49 -0400
Subject: Re: problem with nfs latency during high IO
From: Harshula Jayasuriya <harshula@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>, Judith Flo Gaya <jflo@imppc.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <7D458ECC-9AFB-4791-94EF-736061BD1095@oracle.com>
References: <4D7B6DE5.8010008@imppc.org>
	 <526EE4AA-ABD2-4452-9C3A-C000BD3CFC60@oracle.com>
	 <4D7FA11F.5020604@imppc.org>
	 <21A84B17-E061-4441-9181-100AC8E473E2@oracle.com>
	 <7D458ECC-9AFB-4791-94EF-736061BD1095@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Mar 2011 12:21:24 +1100
Message-ID: <1300324884.7042.4.camel@serendib>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Chuck & Judith,

On Tue, 2011-03-15 at 14:15 -0400, Chuck Lever wrote:
> On Mar 15, 2011, at 2:03 PM, Chuck Lever wrote:
> > On Mar 15, 2011, at 1:25 PM, Judith Flo Gaya wrote:

> >> BTW i understand the time issue, but again, if the version of the
> kernel that the red hat has installed allows me to get the information
> soon, why a newer kernel in fedora does not?
> > 
> > Sounds like a bug.  Fedora kernels newer than 2.6.32 should work as
> well as, or better than, RHEL 6.
> 
> Looks like commit acdc53b2 "NFS: Replace __nfs_write_mapping with
> sync_inode()" removes the code that holds i_mutex while trying to
> flush writes before a GETATTR.  This means application writes can
> possibly starve a stat(2) call.  Trond, this seems like a
> regression...?

RHEL 6.0 released with RH kernel 2.6.32-71 and it *does* contain the
commit acdc53b2 "NFS: Replace __nfs_write_mapping with sync_inode()"
backported to 2.6.32. So, I doubt that the reported bad Fedora
performance is due to that commit.

cya,
#

