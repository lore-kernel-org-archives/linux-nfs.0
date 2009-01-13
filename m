Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:38152 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757340AbZAMXMO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2009 18:12:14 -0500
Message-ID: <496D1DE5.8050607@melbourne.sgi.com>
Date: Wed, 14 Jan 2009 10:04:05 +1100
From: Greg Banks <gnb@melbourne.sgi.com>
To: Peter Staubach <staubach@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS ML <linux-nfs@vger.kernel.org>
Subject: Re: [patch 2/3] knfsd: avoid overloading the CPU scheduler with enormous
 load averages
References: <20090113102633.719563000@sgi.com> <20090113102653.664553000@sgi.com> <496CA61C.5050208@redhat.com> <496D1294.1060407@melbourne.sgi.com> <496D1735.40903@redhat.com>
In-Reply-To: <496D1735.40903@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Peter Staubach wrote:
> Greg Banks wrote:
>
> It would be interesting to get some better information regarding
> some of the measurable performance ramifications such as SFS
> though.  
My NFS server work got SpecSFS to the condition of being disk subsystem
bound instead of CPU bound, at which point it was the XFS folks' problem.
> The Linux NFS server has not had much attention paid to
> it 
It's had attention paid to it, just not yet published :-(

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

