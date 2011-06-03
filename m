Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:61233 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988Ab1FCP1X convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jun 2011 11:27:23 -0400
Subject: Re: [PATCH] nfs4: v4 mounts should not need rpcbind running
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DE8FA35.4010606@RedHat.com>
Date: Fri, 3 Jun 2011 11:27:11 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D41B8574-7412-4815-85C7-9287E13FAB26@oracle.com>
References: <1307110290-30672-1-git-send-email-steved@redhat.com> <A51F73EF-B137-4279-91BC-4B7E868CDCB6@oracle.com> <4DE8FA35.4010606@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 3, 2011, at 11:13 AM, Steve Dickson wrote:

> On 06/03/2011 10:41 AM, Chuck Lever wrote:
>> Hey-
>> 
>> On Jun 3, 2011, at 10:11 AM, Steve Dickson wrote:
>> 
>>> This patch makes the nfs4 callback service a hide service
>>> by setting the vs_hidden flag in the nfs4_callback_version4
>>> structure
>> 
>> One reason to continue to do this is to have some assurance that no-one else takes the same RPC program number.  Not a big deal.
> Personally I think its a waste of cycles especially when a large
> number of mounts are happening at once... Its completely overkill IMHO...

Agreed, and I'm not objecting to this specific change.  The above was just a generic observation.

My overall concern, though, was that we might still be hanging at mount or umount time if rpcbind was absent.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




