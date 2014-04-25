Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:49173 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbaDYNbM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2014 09:31:12 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Crash in 3.14.0+ (plus hacks)
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140425110409.GA27561@infradead.org>
Date: Fri, 25 Apr 2014 09:30:28 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Ben Greear <greearb@candelatech.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2191C93E-A3D0-493B-8459-931CE9C59B53@oracle.com>
References: <5346D22A.10102@candelatech.com> <20140425104803.GD22295@fieldses.org> <20140425110409.GA27561@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 25, 2014, at 7:04 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, Apr 25, 2014 at 06:48:03AM -0400, J. Bruce Fields wrote:
>> On Thu, Apr 10, 2014 at 10:17:30AM -0700, Ben Greear wrote:
>>> This could be related to some changes I made to nfs, but in case the
>>> problem is obvious, here's the stack trace.
>> 
>> There's also a report here:
>> 
>> 	https://bugzilla.kernel.org/show_bug.cgi?id=74721
>> 
>> While I'm travelling, I'm cc'ing Christoph in case this might be a
>> consequence of his recent ACL cleanup?
> 
> Chuck already sent a patch in reply to this bug report:
> 
> 	[PATCH] tmpfs: Fix simple_set_acl()

FWIW, Ben reports this patch fixes the crash for him.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



