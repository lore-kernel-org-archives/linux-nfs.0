Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17339 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932096Ab1D0OQs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2011 10:16:48 -0400
Subject: Re: [PATCH] nfsstat: reorder nfs4 stats for 2.6.38 and up
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, steved@redhat.com,
        linux-nfs@vger.kernel.org
In-Reply-To: <4DB7A084.2060009@panasas.com>
References: <1303461980-6731-1-git-send-email-bhalevy@panasas.com>
	 <23EF6F61-46F2-431B-8A44-A3E941688D65@oracle.com>
	 <4DB7A084.2060009@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Apr 2011 10:16:46 -0400
Message-ID: <1303913806.13195.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-27 at 07:50 +0300, Benny Halevy wrote:
> On 2011-04-25 17:11, Chuck Lever wrote:
> > Hey all-
> > 
> > So what are we going to do when adding NFSv4.2 to this mix?  Will we
> > then have to freeze both the NFSv4.1 and NFSv4.0 procedure API in the
> > kernel?  Seems painful.
> 
> Good question.
> How about changing the stat pseudo-file format to include an op
> identifier along with its respective counter, printing a line per op?

We already have that in /proc/self/mountstats


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

