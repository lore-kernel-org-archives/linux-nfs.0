From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] NFSD: do not return nfserr_symlink for the LINK operation
Date: Thu, 19 Mar 2009 11:53:32 +0200
Message-ID: <49C2161C.3020706@panasas.com>
References: <49AF9C28.8030603@cn.fujitsu.com> <49AFA4E4.50207@panasas.com> <20090306213234.GB1779@fieldses.org> <49B2C404.3060907@panasas.com> <20090309180643.GB9408@fieldses.org> <49BA15B3.2040904@cn.fujitsu.com> <20090318230621.GK18894@fieldses.org> <49C1EB55.8060700@panasas.com> <49C1ED5B.6040000@cn.fujitsu.com> <49C1EE65.7010008@panasas.com> <49C1FFC7.6070709@cn.fujitsu.com> <49C20F6F.2040704@panasas.com> <49C210BF.4040101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Ni Wenjuan <niwj@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:21827 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752788AbZCSJxh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2009 05:53:37 -0400
In-Reply-To: <49C210BF.4040101@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 19, 2009, 11:30 +0200, Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
> Benny Halevy wrote:
>> On Mar. 19, 2009, 10:18 +0200, Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>>> Benny Halevy wrote:
>>>> On Mar. 19, 2009, 8:59 +0200, Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>>>>> Benny Halevy wrote:
>>>>>> As reported by Ni Wenjuan <niwj@cn.fujitsu.com> on 2009-03-05:
>>>>>>> the result of newpynfs test case of  LINK4a .  if you link with target directoty
>>>>>>> is a symbole file,it should get NFS4ERR_NOTDIR ,instead got NFS4ERR_SYMLINK.
>>>>>> THE LINK operation doesn't list NFS4ERR_SYMLINK as a valid error in the spec.
>>>>>> Although NFS4ERR_SYMLINK seems like a reasonable error and even though
>>>>>> it was added for LINK in NFSv4.1 we should still return NFSERR_NOTDIR for
>>>>>> nfsv[234].
>>>>> HI,Benny:
>>>>> There are other places that have the same problem,i'm preparing a all-in-one
>>>>> patch.^!^
>>>> Cool.
>>>> Bruce, please ignore this patch then.
>>>>
>>>> Thanks!
>>> There are four placees that returned inappropriate err nfserr_symlink accroding to 
>>> newpynfs test #LINK4a#LOOKP2a#OPCF3a#SATT12a.nfserr_symlink do not listed
>>> in these operations's err list in the spec.
>>> For LINK and LOOKUPP operation,nfserr_notdir should be returned.
>>> For OPEN_CONFIRM and SETATTR operation,nfserr_inval should be returned.
>> Is the issue with SETATTR limited to length-changing ones?
> 
> Sorry,Do not quite understand you:(What do you mean?

It seems like nfserr_symlink would have been returned for
SETATTR only if the client set the size attribute, where
SETATTR must only performed on a regular file (or a named
attribute, I believe).

[Sigh, looking at the code - it looks like we'll return
NFS4ERR_ISDIR for a length-changing SETATTR operating
on a directory.  This is fine in NFSv4.0 but this error
was removed for SETATTR in nfs4.1.  Note to self: revise
this in the nfs41 tree]

Benny

> 
>> Is so, I think it should be indicated in the commit message.
>>
>> Other than that, minor style nit: there seems to be missing
>> space character before all closing comments "*/"...
> 
> Thanks Benny,will fix it.
> 
>> Benny
>>
>>> Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>
>>>
>>> ---
>>>  fs/nfsd/nfs4proc.c  |    6 +++++-
>>>  fs/nfsd/nfs4state.c |    6 +++++-
>>>  fs/nfsd/vfs.c       |    6 ++++++
>>>  3 files changed, 16 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>>> index 9fa60a3..d25e7cf 100644
>>> --- a/fs/nfsd/nfs4proc.c
>>> +++ b/fs/nfsd/nfs4proc.c
>>> @@ -493,8 +493,12 @@ nfsd4_lookupp(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>>  		return nfserr_noent;
>>>  	}
>>>  	fh_put(&tmp_fh);
>>> -	return nfsd_lookup(rqstp, &cstate->current_fh,
>>> +	ret = nfsd_lookup(rqstp, &cstate->current_fh,
>>>  			   "..", 2, &cstate->current_fh);
>>> +	/* nfserr_symlink returned is inappropriate for LOOKUPP*/
>>> +	if (ret == nfserr_symlink)
>>> +		ret = nfserr_notdir;
>>> +	return ret;
>>>  }
>>>  
>>>  static __be32
>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>> index b6f60f4..fe274fc 100644
>>> --- a/fs/nfsd/nfs4state.c
>>> +++ b/fs/nfsd/nfs4state.c
>>> @@ -2234,8 +2234,12 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>>  			cstate->current_fh.fh_dentry->d_name.name);
>>>  
>>>  	status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0);
>>> -	if (status)
>>> +	if (status) {
>>> +		/* nfserr_symlink returned is inappropriate for OPEN_CONFIRM*/
>>> +		if (status == nfserr_symlink)
>>> +			status = nfserr_inval;
>>>  		return status;
>>> +	}
>>>  
>>>  	nfs4_lock_state();
>>>  
>>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
>>> index 6e50aaa..69eba75 100644
>>> --- a/fs/nfsd/vfs.c
>>> +++ b/fs/nfsd/vfs.c
>>> @@ -397,6 +397,9 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>>>  		if (EX_ISSYNC(fhp->fh_export))
>>>  			write_inode_now(inode, 1);
>>>  out:
>>> +	/* nfserr_symlink returned is inappropriate for SETATTR*/
>>> +	if (err == nfserr_symlink)
>>> +		err = nfserr_inval;
>>>  	return err;
>>>  
>>>  out_nfserr:
>>> @@ -1637,6 +1640,9 @@ out_dput:
>>>  out_unlock:
>>>  	fh_unlock(ffhp);
>>>  out:
>>> +	/* nfserr_symlink returned is inappropriate for LINK*/
>>> +	if (err == nfserr_symlink)
>>> +		err = nfserr_notdir;
>>>  	return err;
>>>  
>>>  out_nfserr:
>>
> 
> 
