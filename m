Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:37288 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684Ab1DLQt2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2011 12:49:28 -0400
Subject: Re: [ANNOUNCE] fedfs-utils for Linux
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110412155431.GA8583@infradead.org>
Date: Tue, 12 Apr 2011 12:48:18 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        autofs@linux.kernel.org, util-linux-ng@vger.kernel.org
Message-Id: <8086DF6B-252D-4746-AA6E-A6A85FEDAAE5@oracle.com>
References: <AB0460DE-A056-47AA-B387-156D35334E04@oracle.com> <20110412155431.GA8583@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 12, 2011, at 11:54 AM, Christoph Hellwig wrote:

> On Thu, Apr 07, 2011 at 04:24:29PM -0400, Chuck Lever wrote:
>> See http://oss.oracle.com/projects/fedfs-utils for more information and source code downloads.  Two mailman mailing lists are also available:
>> 
>>  fedfs-utils-announce@oss.oracle.com
>>  fedfs-utils-devel@oss.oracle.com
> 
> Is it really a good idea to not just one but two separate mailinglist
> for something tightly integrated with nfs anyway?  Why not just use
> linux-nfs for the small amount of additional traffic?

FedFS is agnostic to the underlying file protocol.  The current Linux FedFS prototype happens to be NFS-only, but we don't expect it to stay that way.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




