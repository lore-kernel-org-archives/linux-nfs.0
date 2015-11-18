Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39833 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755189AbbKRTTu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Nov 2015 14:19:50 -0500
Subject: Re: [RFC PATCH 1/2] exportfs: pass export option flags to the kernel
 when testing export
To: Jeff Layton <jlayton@poochiereds.net>
References: <1447865430-28434-1-git-send-email-jeff.layton@primarydata.com>
 <20151118141659.5293d648@synchrony.poochiereds.net>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org, bfields@fieldses.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <564CCF55.3010407@RedHat.com>
Date: Wed, 18 Nov 2015 14:19:49 -0500
MIME-Version: 1.0
In-Reply-To: <20151118141659.5293d648@synchrony.poochiereds.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/18/2015 02:16 PM, Jeff Layton wrote:
> On Wed, 18 Nov 2015 11:50:29 -0500
> Jeff Layton <jlayton@poochiereds.net> wrote:
> 
>> test_export takes a flag that just says whether to pass in the fsid or
>> not. This means that all we can test is the NFSEXP_FSIDi flag.
>>
>> Instead of doing that, pass in the actual export options that we
>> intend to use (sometimes or'ed with NFSEXP_FSID to test whether that
>> might be the reason for the failure).
>>
>> This allows us to test the actual export options that we plan to use,
>> and can allow the kernel to vet them properly before mount time.
>>
>> The rationale here is a patch that I have that will add the ability
>> for filesystems to opt out of subtree checking when they can't
>> properly support it.
>>
>> Cc: Neil Brown <neilb@suse.de>
>> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
>> ---
>>  utils/exportfs/exportfs.c | 10 +++++-----
>>  1 file changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
>> index c7a79a69b5d6..cac01fc25f9a 100644
>> --- a/utils/exportfs/exportfs.c
>> +++ b/utils/exportfs/exportfs.c
>> @@ -531,7 +531,7 @@ static int can_test(void)
>>  	return 1;
>>  }
>>  
>> -static int test_export(char *path, int with_fsid)
>> +static int test_export(char *path, int opts)
>>  {
>>  	/* beside max path, buf size should take protocol str into account */
>>  	char buf[NFS_MAXPATHLEN+1+64] = { 0 };
>> @@ -545,7 +545,7 @@ static int test_export(char *path, int with_fsid)
>>  	qword_add(&bp, &len, path);
>>  	if (len < 1)
>>  		return 0;
>> -	snprintf(bp, len, " 3 %d 65534 65534 0\n", with_fsid ? NFSEXP_FSID : 0);
>> +	snprintf(bp, len, " 3 %d 65534 65534 0\n", opts);
>>  	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
>>  	if (fd < 0)
>>  		return 0;
>> @@ -587,12 +587,12 @@ validate_export(nfs_export *exp)
>>  
>>  	if ((exp->m_export.e_flags & NFSEXP_FSID) || exp->m_export.e_uuid ||
>>  	    fs_has_fsid) {
>> -		if ( !test_export(path, 1)) {
>> +		if ( !test_export(path, exp->m_export.e_flags)) {
>>  			xlog(L_ERROR, "%s does not support NFS export", path);
>>  			return;
>>  		}
>> -	} else if ( ! test_export(path, 0)) {
>> -		if (test_export(path, 1))
>> +	} else if ( ! test_export(path, exp->m_export.e_flags)) {
>> +		if (test_export(path, exp->m_export.e_flags & NFSEXP_FSID))
> 
> Duh, that should of course be "exp->m_export.e_flags | NFSEXP_FSID".
> I'll plan to resend after I wait a bit for others to comment. Please
> don't merge this as-is though -- it obviously needs better testing.
> 
> We might be able to simplify the above logic a little too...hmmm...
That logic did look a bit odd... I'll wait for the next version....

steved.

> 
>>  			xlog(L_ERROR, "%s requires fsid= for NFS export", path);
>>  		else
>>  			xlog(L_ERROR, "%s does not support NFS export", path);
> 
> 
