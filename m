Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36574 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdAOHz0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2017 02:55:26 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so2559967pgf.3
        for <linux-nfs@vger.kernel.org>; Sat, 14 Jan 2017 23:55:26 -0800 (PST)
Subject: Re: [PATCH] NFSv4.2: Fix file creating with O_EXCL get a bad mode
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <a76cec59-f007-5c26-dc26-4cc8a6e4daef@gmail.com>
 <20170112204722.GC10501@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>,
        Matthieu Herrb <matthieu.herrb@laas.fr>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <d1e320f8-152e-b700-a33d-37d4426503ad@gmail.com>
Date: Sun, 15 Jan 2017 15:55:16 +0800
MIME-Version: 1.0
In-Reply-To: <20170112204722.GC10501@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/13/2017 04:47, J. Bruce Fields wrote:
> On Sat, Jan 07, 2017 at 10:45:47PM +0800, Kinglong Mee wrote:
>> Acorrding to Matthieu Herrb's test cases, a new created file will
>> get a bad mode as 0666 (expected 0644) after commit dff25ddb4808
>> "nfs: add support for the umask attribute".
>>
>> It is caused by missing check of FATTR4_WORD2_MODE_UMASK
>> in nfs4_exclusive_attrset.
> 
> I don't understand:
> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 6dcbc5d..a3e9ef1 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2697,7 +2697,8 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata,
>>  		sattr->ia_valid |= ATTR_MTIME;
>>  
>>  	/* Except MODE, it seems harmless of setting twice. */
>> -	if ((attrset[1] & FATTR4_WORD1_MODE))
>> +	if ((attrset[1] & FATTR4_WORD1_MODE) ||
>> +	    (attrset[2] & FATTR4_WORD2_MODE_UMASK))
>>  		sattr->ia_valid &= ~ATTR_MODE;
> 
> If I'm understanding this function correctly, attrset is the set of
> attributes which the server tells us were used to store the verifier.
> 
> But mode_umask would never be a sensible place to store the
> verifier, so if the server's response really says that then something's
> wrong.

There are some differences between EXCLUSIVE4 and EXCLUSIVE4_1,
according to rfc5661 18.16.4, 

   After the client has performed a successful exclusive create, the
   attrset response indicates which attributes were used to store the
   verifier.  If EXCLUSIVE4 was used, the attributes set in attrset were
   used for the verifier.  If EXCLUSIVE4_1 was used, the client
   determines the attributes used for the verifier by comparing attrset
   with cva_attrs.attrmask; any bits set in the former but not the
   latter identify the attributes used to store the verifier.  The
   client MUST immediately send a SETATTR to set attributes used to
   store the verifier.  Until it does so, the attributes used to store
   the verifier cannot be relied upon.  The subsequent SETATTR MUST NOT
   occur in the same COMPOUND request as the OPEN.

I think, this patch is a hacker implement for EXCLUSIVE4_1 that just
treat the FATTR4_WORD1_TIME_ACCESS and FATTR4_WORD1_TIME_MODIFY for
exclusive verifier as EXCLUSIVE4. 

Maybe we need update the implement of EXCLUSIVE4_1's verifier checking.

thanks,
Kinglong Mee

> 
> We should probably look at a network trace.
> 
> --b.
> 
>>  
>>  	if (attrset[2] & FATTR4_WORD2_SECURITY_LABEL)
>> -- 
>> 2.9.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
