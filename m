Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63559 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194Ab1KRSXs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 13:23:48 -0500
Message-ID: <1321640624.2653.5.camel@lade.trondhjem.org>
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: John Hughes <john@Calva.COM>, Jeff Layton <jlayton@redhat.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Fri, 18 Nov 2011 20:23:44 +0200
In-Reply-To: <20111118175409.GA1347@umich.edu>
References: <00c101cca615$c2e08db6$78be630a@hq.netapp.com>
	 <20111118175409.GA1347@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-18 at 12:54 -0500, Jim Rees wrote: 
> Myklebust, Trond wrote:
> 
>   So what are they supposed to do without tickets? Crash?
> 
> No, why would they want to do that?
> 
> I feel like I've entered the Twilight Zone here, so please continue without
> me while I dig up the relevant background info.

The point is that if the server won't allow them to issue read or write
system calls, then there are 2 options available to them: 

     1. hang until someone renews their ticket 
     2. get an error which means crash, since most (all?) applications
        aren't written according to the non-posix assumption that read
        and write can return EACCES/EKEYEXPIRED errors.



Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

