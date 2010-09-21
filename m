Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755823Ab0IUTgc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Sep 2010 15:36:32 -0400
Subject: Re: [bfields@pop.test.fieldses.org: all f08d6374 Merge branch
 'nfs-for-next' into linux-next results]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20100921192005.GC4385@fieldses.org>
References: <20100918171546.GA9859@fieldses.org>
	 <1284831680.2787.1.camel@heimdal.trondhjem.org>
	 <20100919184549.GD32071@fieldses.org> <20100920130106.GB4580@fieldses.org>
	 <20100920131025.GC4580@fieldses.org>
	 <1285091815.30222.19.camel@heimdal.trondhjem.org>
	 <20100921111657.330e7838@corrin.poochiereds.net>
	 <20100921192005.GC4385@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Sep 2010 15:36:26 -0400
Message-ID: <1285097787.30222.24.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-09-21 at 15:20 -0400, J. Bruce Fields wrote:
> All I need to do is mount nfs4.1 and run cthon -s.  The last output I
> see from the test is:
> 
> check for proper open/unlink operation
> nfsjunk files before unlink:
>   

Oh... I bet I see what it is.

It's that damned res->sr_slotid = NFS4_MAX_SLOT_TABLE and related
initialisation junk that's biting us in the arse again...

I'll fix it...

Trond
