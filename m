Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757794Ab0HDNo7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 09:44:59 -0400
Message-ID: <4C596ED4.5010707@RedHat.com>
Date: Wed, 04 Aug 2010 09:44:52 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 08/24] Removed warnings from mountd.c
References: <1279669057-17509-1-git-send-email-steved@redhat.com> <1279669057-17509-9-git-send-email-steved@redhat.com> <20100721171251.GB26418@fieldses.org>
In-Reply-To: <20100721171251.GB26418@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 07/21/2010 01:12 PM, J. Bruce Fields wrote:
> On Tue, Jul 20, 2010 at 07:37:21PM -0400, Steve Dickson wrote:
>> mountd.c: In function 'mount_null_1_svc':
>> mountd.c:195: warning: unused parameter 'rqstp'
>> mountd.c:195: warning: unused parameter 'argp'
>> mountd.c:195: warning: unused parameter 'resp'
>> mountd.c: In function 'mount_dump_1_svc':
>> mountd.c:213: warning: unused parameter 'argp'
> ...
>> @@ -214,7 +217,8 @@ mount_dump_1_svc(struct svc_req *rqstp, void *argp, mountlist *res)
>>  {
>>  	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
>>  
>> -	xlog(D_CALL, "dump request from %s.", inet_ntoa(addr->sin_addr));
>> +	xlog(D_CALL, "MNT1(%s) dump request: argp %p", 
>> +		inet_ntoa(addr->sin_addr), argp);
> 
> Since those are unused, adding them to the debugging log doesn't add any
> useful information.
Well knowing that a client just sent a dump request when debug
is enabled verses not knowing with debug enabled seems it might be 
somewhat useful... 

> 
> The extra warnings is maybe a useful exercise to do every now and then
> to check if it turns up bugs, but I'm not sure forcing all the code to
> pass those tests is worthwhile.
Really... Maybe I'm misunderstanding you but forcing all the code to
compile warning free is a really good thing... 

steved.

