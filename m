Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:17997 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286Ab1LEUTO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 15:19:14 -0500
Subject: Re: Empty core dumps on NFSv4 mounts
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C544D70@SACMVEXC2-PRD.hq.netapp.com>
Date: Mon, 5 Dec 2011 15:19:05 -0500
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Message-Id: <A288911B-E32B-4C09-9662-C30C5E2EEB33@oracle.com>
References: <AD82E120-D2B9-4C11-A622-970C951BD4F4@oracle.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C544D70@SACMVEXC2-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 5, 2011, at 3:14 PM, Myklebust, Trond wrote:

> No. There have been no kernel idmapper changes since then.
> 
> The correct thing to do here is to cache the string name in struct
> nfs_fattr, and then do the upcall from the caller of OPEN. I believe
> that Arnaud wrote a patch to do this, however the whole pNFS merge got
> in my way of reviewing this. Feel free to take a look at what he did,
> and post comments...

We're looking at his patch, from July 2010, now.  It calls kmalloc() in the XDR decoder.  Is there a newer version?

> Cheers
>  Trond
> 
>> -----Original Message-----
>> From: Chuck Lever [mailto:chuck.lever@oracle.com]
>> Sent: Monday, December 05, 2011 3:10 PM
>> To: Myklebust, Trond
>> Cc: Linux NFS Mailing List
>> Subject: Empty core dumps on NFSv4 mounts
>> 
>> Bump.
>> 
>> http://comments.gmane.org/gmane.linux.nfs/33390
>> 
>> We have evidence that this is still occurring as late as 3.0.  Have
> recent
>> idmapper changes addressed this issue?
>> 
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




