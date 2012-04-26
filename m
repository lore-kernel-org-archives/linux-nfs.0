Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753848Ab2DZUCE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 16:02:04 -0400
Message-ID: <4F99878C.2050903@RedHat.com>
Date: Thu, 26 Apr 2012 13:36:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] mounts.nfs: v2 and v3 background mounts should retry
 when server is down.
References: <1335368390-26767-1-git-send-email-steved@redhat.com> <56A41F90-A936-4926-B532-E6600655025E@oracle.com>
In-Reply-To: <56A41F90-A936-4926-B532-E6600655025E@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/25/2012 04:31 PM, Chuck Lever wrote:
> Hi-
> 
> On Apr 25, 2012, at 11:39 AM, Steve Dickson wrote:
> 
>> The point of background mounts is to have the mount
>> retried if the mount fails. This patch allows the v2/v3
>> background mount to proceed in the case when the server
>> is down by not making EOPNOTSUPP a permanent error.
> 
> Just curious... why wouldn't we want to do this for foreground mounts as well?
I had a similar thought but I was worried that it would change the
current behavior that people are depending on... Giving the
option of putting the mount in back ground to wait I thought
was a good compromise... 

steved.
