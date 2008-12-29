From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 05/22] NFSD: Add helper functions for __write_ports()
Date: Mon, 29 Dec 2008 13:42:33 -0500
Message-ID: <20081229184233.GC13756@fieldses.org>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net> <20081212215742.24332.36578.stgit@ingres.1015granger.net> <20081225041523.GA17998@fieldses.org> <722B1063-9532-4F1C-9214-C7D9DFF3CA3F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:39261 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089AbYL2Smh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Dec 2008 13:42:37 -0500
In-Reply-To: <722B1063-9532-4F1C-9214-C7D9DFF3CA3F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 29, 2008 at 12:04:29PM -0500, Chuck Lever wrote:
> On Dec 24, 2008, at Dec 24, 2008, 11:15 PM, J. Bruce Fields wrote:
>> On Fri, Dec 12, 2008 at 04:57:42PM -0500, Chuck Lever wrote:
>>> Clean up:  I'd like to refactor __write_ports() to make it easier to
>>> understand and maintain.  Introduce a set of helper functions to
>>> handle the details of the __write_ports() function.
>>>
>>> New helpers are not used yet.
>>
>> As stated in http://marc.info/?l=linux-nfs&m=122894134032274&w=2, I'd
>> prefer that new code be introduced with its callers where reasonable, 
>> so
>> in this case I'd rather this patch be combined with the following.
>
> Right, I wrote these patches well before the referenced e-mail, and  
> split them this way because the diff of the combined changes is well- 
> nigh impossible to read.
>
> What I may end up doing instead is splitting these helpers out one patch 
> at a time.  That should make for more legible patches.

Yes, I think that's the more natural split.

--b.
