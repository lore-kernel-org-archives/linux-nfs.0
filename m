Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.tpi.com ([70.99.223.143]:3612 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756016Ab3BMOkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2013 09:40:31 -0500
Message-ID: <511BA5D5.6050902@canonical.com>
Date: Wed, 13 Feb 2013 07:40:21 -0700
From: Tim Gardner <tim.gardner@canonical.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH linux-next] lockd: nlmsvc_mark_resources(): avoid stack
 overflow
References: <1360698538-63040-1-git-send-email-tim.gardner@canonical.com> <20130212212246.GH10267@fieldses.org>
In-Reply-To: <20130212212246.GH10267@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/12/2013 02:22 PM, J. Bruce Fields wrote:
> On Tue, Feb 12, 2013 at 12:48:58PM -0700, Tim Gardner wrote:
>> Dynamically allocate the NLM host structure in order to avoid stack overflow.
>> nlmsvc_mark_resources() is several call levels deep in a stack
>> that has a number of large variables. 512 bytes seems like a lot
>> on the stack at this point.
>>
>> smatch analysis:
>>
>> fs/lockd/svcsubs.c:366 nlmsvc_mark_resources() warn: 'hint' puts
>>  512 bytes on stack
>>
>> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Cc: "J. Bruce Fields" <bfields@fieldses.org>
>> Cc: linux-nfs@vger.kernel.org
>> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
>> ---
>>  fs/lockd/svcsubs.c |   12 ++++++++----
>>  1 file changed, 8 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
>> index b904f41..f3abb7f 100644
>> --- a/fs/lockd/svcsubs.c
>> +++ b/fs/lockd/svcsubs.c
>> @@ -363,11 +363,15 @@ nlmsvc_is_client(void *data, struct nlm_host *dummy)
>>  void
>>  nlmsvc_mark_resources(struct net *net)
>>  {
>> -	struct nlm_host hint;
>> +	struct nlm_host *hint = kzalloc(sizeof(*hint), GFP_KERNEL);
>>  
>> -	dprintk("lockd: nlmsvc_mark_resources for net %p\n", net);
>> -	hint.net = net;
>> -	nlm_traverse_files(&hint, nlmsvc_mark_host, NULL);
>> +	if (hint) {
>> +		dprintk("lockd: nlmsvc_mark_resources for net %p\n", net);
>> +		hint->net = net;
>> +		nlm_traverse_files(hint, nlmsvc_mark_host, NULL);
>> +	}
> 
> Silently neglecting to do this looks like a bad idea.
> 
> It's strange that we're passing in an nlm_host when all we actually use
> is the struct net*.  Why not just change this to pass in the net
> instead?
> 
> --b.
> 

It won't really be silent. k[zm]alloc() dumps a stack trace on failure
to allocate unless GFP_NOWARN is set in the flags. I think this is a bit
better then possibly corrupting the stack.

Changing the prototype to just pass in 'net' has knock on effects that
make this patch a whole lot bigger. You'd have to change the code within
a bunch of functions which are difficult to verify at compile time
because of the use of 'void *data' as the first parameter. Is there
still a good reason for that parameter to be opaque ?

rtg
-- 
Tim Gardner tim.gardner@canonical.com
