From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: NFS4ERR_SYMLINK  error
Date: Sat, 07 Mar 2009 20:59:16 +0200
Message-ID: <49B2C404.3060907@panasas.com>
References: <49AF9C28.8030603@cn.fujitsu.com> <49AFA4E4.50207@panasas.com> <20090306213234.GB1779@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ni Wenjuan <niwj@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:16980 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753806AbZCGTAV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Mar 2009 14:00:21 -0500
In-Reply-To: <20090306213234.GB1779@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 06, 2009, 23:32 +0200, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Thu, Mar 05, 2009 at 12:09:40PM +0200, Benny Halevy wrote:
>> On Mar. 05, 2009, 11:32 +0200, Ni Wenjuan <niwj@cn.fujitsu.com> wrote:
>>> the result of newpynfs test case of  LINK4a .  if you link with target directoty
>>>  is a symbole file,it should get NFS4ERR_NOTDIR ,instead got NFS4ERR_SYMLINK.
>>>
>>> THE LINK operation  don't list NFS4ERR_SYMLINK as valid errors in the spec. But
>>> NFS4ERR_SYMLINK seems like a reasonable error.  Is this an oversight
>>> in the spec, or something we need to fix?
>> Although NFSv4.1 adds NFS4ERR_SYMLINK to LINK's allowed errors list
>> (and this might be an indication for it being an oversight in rfc3530),
> 
> The error lists in rfc3530 are known to be incomplete in some cases, so
> before adding an exception like this I'd like something more.  (E.g.:
> does this cause any client or application to fail?  Is there some
> logical reason notdir is a more useful error than symlink?)

FWIW, the linux nfs client translates NFS4ERR_SYMLINK to -ELOOP
which is awkward and less descriptive to the app / user than
-ENOTDIR.  That said, I don't think a careful client implementation
should ever get NFS4ERR_SYMLINK if it stats the directory it operates
on before sending the link op (or lookup, create, rename, etc.) to make
sure it is indeed a directory, right?.

Benny

> 
> --b.
> 
>> NFSv4.0 doesn't allow it so this needs to be fixed.
>>
>> Can you please test the following patch?
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>
>> git diff --stat -p fs/nfsd/vfs.c
>>  fs/nfsd/vfs.c |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>> index 6e50aaa..9165b1f 100644
>> --- a/fs/nfsd/vfs.c
>> +++ b/fs/nfsd/vfs.c
>> @@ -1637,6 +1637,9 @@ out_dput:
>>  out_unlock:
>>  	fh_unlock(ffhp);
>>  out:
>> +	/* nfserr_symlink returned from fh_verify is inappropriate for LINK */
>> +	if (err == nfserr_symlink)
>> +		err = nfserr_notdir;
>>  	return err;
>>  
>>  out_nfserr:
>>
>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
