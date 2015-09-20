Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33878 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969AbbITJ4z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 05:56:55 -0400
Received: by padhy16 with SMTP id hy16so89605151pad.1
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 02:56:54 -0700 (PDT)
Subject: Re: [PATCH] nfs: Fix open state losing after delegation return
To: Neil Brown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
References: <55FA8D22.2010003@gmail.com>
 <87fv294r5u.fsf@notabene.neil.brown.name>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55FE82D9.4040305@gmail.com>
Date: Sun, 20 Sep 2015 17:56:41 +0800
MIME-Version: 1.0
In-Reply-To: <87fv294r5u.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/20/2015 13:05, Neil Brown wrote:
> Kinglong Mee <kinglongmee@gmail.com> writes:
> 
>> After delegation return caused by setting file mode, 
>> client lost the open state,  DESTROY_CLIENTID will 
>> get error NFS4ERR_CLIENTID_BUSY from server.
>>
>> The delegation_type passed to nfs4_open_recover_helper
>> with NFS4_OPEN_CLAIM_DELEG_CUR_FH is never set.
>>
>> Reproduce steps,
>> # mount -t nfs nfs-server:/ /mnt/

Missing a step, 
# touch /mnt/test1 /mnt/test2

>> # ./delegation_test /mnt/
>> # umount /mnt    <--- costs 10 seconds
>>
>> The delegation_test.c is,
>> #include <stdio.h>
>> #include <stdlib.h>
>> #include <sys/types.h>
>> #include <unistd.h>
>> #include <sys/stat.h>
>> #include <fcntl.h>
>> #include <error.h>
>>
>> int main(int argc, char **argv)
>> {
>>         int fd1, fd2;
>>         char fname1[1024], fname2[1024];
>>         struct stat sb;
>>
>>         if (argc < 2)
>>                 return -1;
>>
>>         sprintf(fname1, "%s/test1", argv[1]);
>>         sprintf(fname2, "%s/test2", argv[1]);
>>
>>         fd1 = open(fname1, O_RDONLY);
>>         fd2 = open(fname2, O_RDONLY);
>>
>>         fstat(fd1, &sb);
>>         fchmod(fd1, sb.st_mode + 1);
>>
>>         close(fd1);
>>         close(fd2);
>>
>>         return 0;
>> }
>>
>> Fixes: 39f897fdbd ("NFSv4: When returning a delegation, don't reclaim an incompatible open mode.")
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfs/nfs4proc.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 693b903..472a52f 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -1576,8 +1576,7 @@ static int nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmod
>>  	struct nfs4_state *newstate;
>>  	int ret;
>>  
>> -	if ((opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR ||
>> -	     opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEG_CUR_FH) &&
>> +	if (opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR &&
>>  	    (opendata->o_arg.u.delegation_type & fmode) != fmode)
>>  		/* This mode can't have been delegated, so we must have
>>  		 * a valid open_stateid to cover it - not need to reclaim.
>> -- 
>> 2.5.0
> 
> This patches doesn't look right to me.  It isn't at all clear why the
> change given addresses the symptoms described.

There are three places calling nfs4_open_recover(), those open_claim_type
are, NFS4_OPEN_CLAIM_PREVIOUS, NFS4_OPEN_CLAIM_DELEG_CUR_FH and 
NFS4_OPEN_CLAIM_FH.

Only set delegation_type with NFS4_OPEN_CLAIM_PREVIOUS.

So the checking seems wrong here.

> 
> However looking back at my patch (39f897fdbd) it looks really wrong and
> I cannot imagine how I missed the problem when I submitted it.
> 
> nfs4_open_recover assumes that if nfs4_open_recover_helper returns zero,
> the 'newstate' has been given a value and if that doesn't match 'state'
> it returns -ESTALE.
> 
> However with my patch, nfs4_open_recovery_helper can return zero and
> leave 'newstate' uniitialised.  I cannot even see how that passed
> testing :-(

Yes, it's strange.
But it does not affect the problem I reported.
You can send it as a separate patch.

> 
> You could maybe fix with
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 693b903b48bd..6899197ff1c3 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1604,7 +1604,7 @@ static int nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmod
>  
>  static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *state)
>  {
> -	struct nfs4_state *newstate;
> +	struct nfs4_state *newstate = state;
>  	int ret;
>  
>  	/* Don't trigger recovery in nfs_test_and_clear_all_open_stateid */
> 
> but I'm not at all sure I like that.  I'll try to find time to look at
> the code properly and make a more concrete proposal - and to test with
> your test case too.  However you didn't give details on the mount: I
> assume it was a 4.1 mount?  Was it against the Linux nfs server or
> something else?

My default nfs mount is 4.2, 
nfs-server:/ /mnt nfs4 rw,seclabel,relatime,vers=4.2,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.8.128,local_lock=none,addr=192.168.8.128 0 0

The nfs server is a linux with latest kernel 4.3.0-rc1.

thanks,
Kinglong Mee
