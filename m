From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: Problems with default ACLs over NFS
Date: Mon, 20 Apr 2009 11:05:58 +0530
Message-ID: <49EC09BE.6090508@suse.de>
References: <20090323222427.00bb24e7@werewolf.home> <20090326170513.4e7d377a.akpm@linux-foundation.org> <18513.1238194255@jrobl> <49EBFD18.4070607@suse.de> <7064.1240204656@jrobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>, jamagallon-sh/6fXdz2Rs@public.gmane.org,
	LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
	Trond.Myklebust@netapp.com, lists@fuchsschwanzdomain.de
To: hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:46555 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbZDTFgO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Apr 2009 01:36:14 -0400
In-Reply-To: <7064.1240204656@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org wrote:
> Suresh Jayaraman:
>> The following patch from Trond should fix this issue, I think.
>>
>>
>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Date: Wed, 15 Apr 2009 13:58:45 -0400
>> Subject: [PATCH] NFS: Fix the XDR iovec calculation in nfs3_xdr_setaclargs
>>
>> Commit ae46141ff08f1965b17c531b571953c39ce8b9e2 (NFSv3: Fix posix ACL code)
>> introduces a bug in the calculation of the XDR header iovec. In the case
>> where we are inlining the acls, we need to adjust the length of the iovec
>> req->rq_svec, in addition to adjusting the total buffer length.
> 
> Thanx.
> But which tree is this patch applied?
> 

Not yet applied. I guess it's queued up in Trond's git.

Thanks,

-- 
Suresh Jayaraman
