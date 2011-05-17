Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755020Ab1EQOBA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 10:01:00 -0400
Message-ID: <4DD27F93.80201@RedHat.com>
Date: Tue, 17 May 2011 10:00:51 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Removed compilation warnings from mountd/cache.c
References: <1305561014-25688-1-git-send-email-steved@redhat.com> <20110516172927.GA1348@fieldses.org> <20110516191811.GA1048@merit.edu> <20110516192530.GB1680@fieldses.org>
In-Reply-To: <20110516192530.GB1680@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 05/16/2011 03:25 PM, J. Bruce Fields wrote:
> On Mon, May 16, 2011 at 03:18:11PM -0400, Jim Rees wrote:
>> J. Bruce Fields wrote:
>>
>>   On Mon, May 16, 2011 at 11:50:14AM -0400, Steve Dickson wrote:
>>   > Commit 5604b35a6 introduced a number of missing initializer
>>   > warnings that were missed. This patch removes those warnings.
>>   > 
>>   > Signed-off-by: Steve Dickson <steved@redhat.com>
>>   > ---
>>   >  utils/mountd/cache.c |    6 ++++--
>>   >  1 files changed, 4 insertions(+), 2 deletions(-)
>>   > 
>>   > diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>>   > index df6b38f..86a2790 100644
>>   > --- a/utils/mountd/cache.c
>>   > +++ b/utils/mountd/cache.c
>>   > @@ -825,7 +825,6 @@ struct {
>>   >  	char *cache_name;
>>   >  	void (*cache_handle)(FILE *f);
>>   >  	FILE *f;
>>   > -	char vbuf[RPC_CHAN_BUF_SIZE];
>>   >  } cachelist[] = {
>>   >  	{ "auth.unix.ip", auth_unix_ip, NULL},
>>   >  	{ "auth.unix.gid", auth_unix_gid, NULL},
>>   > @@ -833,6 +832,9 @@ struct {
>>   >  	{ "nfsd.fh", nfsd_fh, NULL},
>>   >  	{ NULL, NULL, NULL }
>>   >  };
>>   > +struct vbs {
>>   > +	char vbuf[RPC_CHAN_BUF_SIZE];
>>   > +} vbufs [(sizeof(cachelist)/sizeof(cachelist[0])) - 1];
>>   
>>   Weird--why does that make a difference?  It's statically initialized
>>   memory either way, isn't it?
>>
>> The problem is the vbuf item was added to the struct but no initializer was
>> given for it.  It could also have been fixed by supplying the missing
>> initializer:
>>
>> 	{ "auth.unix.ip", auth_unix_ip, NULL, ""}, ...
> 
> Oh, OK.  Then could we do that, Steve, instead of moving the buffer
> to a separate structure?
Good point... I thought I tried added a "" and it warnings still 
appeared, which was the reason for the extra structure.... I guess
I was a bit confused... because by far adding  "" is a much better fix.... 

thanks!

steved.
