Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:60502 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755679Ab0ICQ2x convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Sep 2010 12:28:53 -0400
Subject: Re: [nfs] nfs:  Fix nfs_sockaddr_match_ipaddr6
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4C8120D3.9040704@candelatech.com>
Date: Fri, 3 Sep 2010 12:27:01 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <2B27FD2F-82C7-4088-A74F-DA8E3E5FEFE7@oracle.com>
References: <1283530511-20658-1-git-send-email-greearb@candelatech.com> <1D980EDC-301A-4B4D-97D3-037B96DBAF86@oracle.com> <4C8120D3.9040704@candelatech.com>
To: Ben Greear <greearb@candelatech.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 3, 2010, at 12:22 PM, Ben Greear wrote:

> On 09/03/2010 09:17 AM, Chuck Lever wrote:
>> 
>> On Sep 3, 2010, at 12:15 PM, Ben Greear wrote:
>> 
>>> A typo caused this method not not actually compare the
>>> two addresses passed in.  It returned true in almost all
>>> cases instead.
>> 
>> From the perspective of the local logic, that looks correct.  Have you tried this with IPv6 mounts?  Notice any overall changes in behavior?
> 
> I noticed this when getting multiple NFS mounts to work with srcaddr=
> 
> The change fixed the problems I was seeing, but I haven't tested w/out
> srcaddr= logic.  Might need to have two different NFS servers to do a good
> test of this logic, and I'm not looking forward to setting up another
> open-solaris box!

OK, so at least it doesn't seem to break anything. :^)

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

-- 
chuck[dot]lever[at]oracle[dot]com




