Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:23203 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758095Ab1COPnu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 11:43:50 -0400
Subject: Re: [PATCH] SUNRPC: svc_register error overwritten in next iteration
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110314223645.GL25442@fieldses.org>
Date: Tue, 15 Mar 2011 11:43:32 -0400
Cc: roel <roel.kluin@gmail.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
Message-Id: <13D041DB-A26D-4EC1-A585-7DBA266CF18A@oracle.com>
References: <4D7B74C7.7060506@gmail.com> <20110314223645.GL25442@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 14, 2011, at 6:36 PM, J. Bruce Fields wrote:

> On Sat, Mar 12, 2011 at 02:27:35PM +0100, roel wrote:
>> The break is in the inner loop, the svc_register() error is overwritten
>> in the next iteration. Only the error in the last iteration is returned.
>> 
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>> ---
>> net/sunrpc/svc.c |    2 ++
>> 1 files changed, 2 insertions(+), 0 deletions(-)
>> 
>> Is this needed?
>> 
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index 08e05a8..5fd08c0 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -889,6 +889,8 @@ int svc_register(const struct svc_serv *serv, const int family,
>> 			if (error < 0)
>> 				break;
> 
> May as well just "goto out" or "return error" here?
> 
> But: aren't we missing some cleanup?  If we succesfully register one
> program then fail at a second one, don't we need to unregister the
> first?

Right.  I don't understand what is the intended effect here (of the original code):  Best effort registration, or "all or none"?

> --b.
> 
>> 		}
>> +		if (error < 0)
>> +			break;
>> 	}
>> 
>> 	return error;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




