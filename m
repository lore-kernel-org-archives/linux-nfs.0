Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085Ab1FEXvz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jun 2011 19:51:55 -0400
Message-ID: <4DEC1692.6070504@RedHat.com>
Date: Sun, 05 Jun 2011 19:51:46 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chucklever@gmail.com>
CC: Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [Libtirpc-devel] [PATCH] Do not skip records with nonblocking
 connections
References: <1307288638-32215-1-git-send-email-steved@redhat.com> <44DFB4C2-AD75-412F-B211-D6DB1B9D2ACE@gmail.com>
In-Reply-To: <44DFB4C2-AD75-412F-B211-D6DB1B9D2ACE@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/05/2011 06:57 PM, Chuck Lever wrote:
> 
> 
> Sent from my iPad
> 
> On Jun 5, 2011, at 11:43 AM, Steve Dickson <steved@redhat.com> wrote:
> 
>> With non-blocking connections, do not skip records when receiving
>> the streams since entire value messages can be ignored which
>> in cause the entire stream to become out of sync.
>>
>> For example, two mounts simultaneously send two unmaps
>> commands. The first one is read, then the second thrown
>> away due to skipping the record. Skipping this record
>> will cause XDR error later in processing of the stream.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> src/svc_vc.c |    5 +++++
>> 1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/src/svc_vc.c b/src/svc_vc.c
>> index aaaf2d7..15dac18 100644
>> --- a/src/svc_vc.c
>> +++ b/src/svc_vc.c
>> @@ -610,6 +610,11 @@ svc_vc_recv(xprt, msg)
>>    }
>>
>>    xdrs->x_op = XDR_DECODE;
>> +    /*
>> +     * No need skip records with nonblocking connections
>> +     */
>> +    if (cd->nonblock == FALSE)
>> +        (void)xdrrec_skiprecord(xdrs);
>>    (void)xdrrec_skiprecord(xdrs);
> 
> Do you want to delete the unconditional invocation of xdrrec_skiprecord() here?
Yes I do... a small cut/past error... good catch!

steved.
> 
>>    if (xdr_callmsg(xdrs, msg)) {
>>        cd->x_id = msg->rm_xid;
>> -- 
>> 1.7.4.4
>>
>>
>> ------------------------------------------------------------------------------
>> Simplify data backup and recovery for your virtual environment with vRanger.
>> Installation's a snap, and flexible recovery options mean your data is safe,
>> secure and there when you need it. Discover what all the cheering's about.
>> Get your free trial download today. 
>> http://p.sf.net/sfu/quest-dev2dev2 
>> _______________________________________________
>> Libtirpc-devel mailing list
>> Libtirpc-devel@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
