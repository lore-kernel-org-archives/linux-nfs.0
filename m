Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:31351 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab2HIUwU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 16:52:20 -0400
Subject: Re: NFS: Treat NFS4ERR_CLID_INUSE as a fatal error
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <24601061-1606-4A0A-940E-FDAFD1A2A2BB@oracle.com>
Date: Thu, 9 Aug 2012 16:52:07 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <39FE3A39-4EB2-4F9F-908F-645C79B30E0F@oracle.com>
References: <20120809183557.GA10591@fieldses.org> <53272628-CC34-4279-AA69-CD31B86672D5@oracle.com> <20120809193743.GD10591@fieldses.org> <20120809203838.GA11538@fieldses.org> <24601061-1606-4A0A-940E-FDAFD1A2A2BB@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 9, 2012, at 4:46 PM, Chuck Lever wrote:

> 
> On Aug 9, 2012, at 4:38 PM, J. Bruce Fields wrote:
> 
>> On Thu, Aug 09, 2012 at 03:37:43PM -0400, J. Bruce Fields wrote:
>>> On Thu, Aug 09, 2012 at 03:06:00PM -0400, Chuck Lever wrote:
>>>> 
>>>> On Aug 9, 2012, at 2:35 PM, J. Bruce Fields wrote:
>>>> 
>>>>> Sorry not to notice this before--the below causes a regression against
>>>>> the Linux server; something like:
>>>>> 
>>>>> 	# mount -osec=krb5i pip1:/exports /mnt/
>>>>> 	# echo "test" >/mnt/test
>>>>> 	# umount /mnt/
>>>>> 	# mount -osec=krb5 pip1:/exports /mnt/
>>>>> 	# echo "test" >/mnt/test
>>>>> 	bash: /mnt/test: Operation not permitted
>>>>> 
>>>>> This fails after the below commit on the client, but not before, thanks
>>>>> to the server rejecting the second setclientid with CLID_INUSE due to a
>>>>> different security flavor.
>>>> 
>>>> This was part of a series where the last few patches got dropped for other problems.  Testing with this patch by itself was never done since it was part of a series of patches that implement a particular feature.
>>>> 
>>>> One thought is to put the authentication flavor name back into nfs_client_id4.id string temporarily until we have worked through the issues with full UCS support.  That would prevent the regression, but we'd still have clients who use multiple authentication flavors maintaining multiple leases.
>>> 
>>> That should work.
>> 
>> Whoops, no, au_name is just "RPCSEC_GSS" in both cases.
> 
> Could you confirm that before that commit, the client had to send an additional SETCLIENTID with a new cl_id_uniquifier?
> 
> We'll need to distinguish the pseudoflavor as well for GSS, apparently.

The client should present the same principal on both SETCLIENTID requests, shouldn't it?  If the principal is the same, that's all that RFC 3530bis requires.  Maybe I don't understand how GSS principals work.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




