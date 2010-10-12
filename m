Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54833 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308Ab0JLUGs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 16:06:48 -0400
Subject: Re: whither NFS umount?
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101012155234.094a87c3@corrin.poochiereds.net>
Date: Tue, 12 Oct 2010 15:59:21 -0400
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <457DDEA3-4989-4B0F-AC90-155949666E7A@oracle.com>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com> <1286903046.24878.13.camel@heimdal.trondhjem.org> <C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com> <20101012151826.76b75f52@corrin.poochiereds.net> <1286912649.1956.19.camel@heimdal.trondhjem.org> <20101012155234.094a87c3@corrin.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 12, 2010, at 3:52 PM, Jeff Layton wrote:

> On Tue, 12 Oct 2010 15:44:09 -0400
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
>> On Tue, 2010-10-12 at 15:18 -0400, Jeff Layton wrote:
>> 
>>> I think the part that causes problems is having userspace do this. In
>>> theory, if the kernel were in charge of sending the UMNT, then it's not
>>> really a problem since it knows when to do it. If we have code that
>>> sends a UMNT already, why not do a best-effort UMNT call from the
>>> kernel when we tear down the sb?
>> 
>> Purely for the pleasure of allowing the server to maintain inaccurate
>> statistics about who is currently mounting what? I think not...
>> 
>> You can get far more accurate results by replacing the MNT/UMNT state
>> counter with a purely server-based scheme to track who accessed one or
>> more files on each exported partition in the past 5 minutes or so. That
>> would even work with NFSv4...
>> 
> 
> True, but for better or worse, UMNT is part of the protocol. It seems
> like we ought to do our best to implement it, even if it is
> fundamentally flawed.

I would like to see the kernel send UMNT, but I don't have a strong technical reason for it.  It's just a best-effort kind of thing.  Besides, we should be conservative in what we send (ie follow the protocol as closely as possible), and liberal in what we receive.

In any event, whether the kernel sends a UMNT or no-one does, we can rip it out of umount.nfs now, I think.

-- 
chuck[dot]lever[at]oracle[dot]com




