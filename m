From: Chuck Lever <chuck.lever-Onf44Ee+mfbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/5] lockd: Add address family-agnostic helper for zeroing the port number
Date: Tue, 26 Aug 2008 15:56:12 -0400
Message-ID: <BE820CD5-33E0-4F61-B6C9-90FFEAB9F6D4@oracle.com>
References: <20080822163939.20488.92983.stgit@manray.1015granger.net> <20080822164232.20488.11685.stgit@manray.1015granger.net> <20080826190319.GF4380@fieldses.org> <20080826191750.GH4380@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:32431 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbYHZT5B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2008 15:57:01 -0400
In-Reply-To: <20080826191750.GH4380@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 26, 2008, at Aug 26, 2008, 3:17 PM, J. Bruce Fields wrote:
> On Tue, Aug 26, 2008 at 03:03:19PM -0400, bfields wrote:
>> It would be nice if not necessary just to move nfs_set_port()  
>> somewhere
>> common and use that (maybe with a more generic name).
>>
>> That aside, all 5 patches are OK by me.
>
> Provisionally applied all but the first (purely client-side) patch to
>
> 	git://linux-nfs.org/~bfields/linux.git for-2.6.28
>
> Do you have any good regression tests for nsm?

Netapp is providing some testing resources.  Their lock recovery tests  
provide some test coverage, but I don't know details.

One of the issues on the list for the Austin bake-a-thon is to review  
our test coverage, and see if we can flesh this out more.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
