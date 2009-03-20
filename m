From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] NFSD: do not return nfserr_symlink for the LINK	operation
Date: Fri, 20 Mar 2009 14:16:28 +0800
Message-ID: <49C334BC.7010001@cn.fujitsu.com>
References: <20090309180643.GB9408@fieldses.org> <49BA15B3.2040904@cn.fujitsu.com> <20090318230621.GK18894@fieldses.org> <49C1EB55.8060700@panasas.com> <49C1ED5B.6040000@cn.fujitsu.com> <49C1EE65.7010008@panasas.com> <49C1FFC7.6070709@cn.fujitsu.com> <49C20F6F.2040704@panasas.com> <49C21485.5070306@cn.fujitsu.com> <20090319200035.GC5499@fieldses.org> <20090319201525.GA6055@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Ni Wenjuan <niwj@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55648 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751201AbZCTGRV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2009 02:17:21 -0400
In-Reply-To: <20090319201525.GA6055@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Mar 19, 2009 at 04:00:35PM -0400, bfields wrote:
>> On Thu, Mar 19, 2009 at 05:46:45PM +0800, Yang Hongyang wrote:
>>> v1->v2:update some code style problem
>>> -------------------------
>>>
>>> There are four placees that returned inappropriate err nfserr_symlink accroding to 
>>> newpynfs test #LINK4a#LOOKP2a#OPCF3a#SATT12a.nfserr_symlink do not listed
>>> in these operations's err list in the spec.
>>> For LINK and LOOKUPP operation,nfserr_notdir should be returned.
>>> For OPEN_CONFIRM and SETATTR operation,nfserr_inval should be returned.
>> I thought Benny found that this also caused the linux client to return a
>> better error in one of these cases--could you confirm that and add a
>> mention of it in the commit message?
>>
>> (I'm reluctant to take patches like this based *only* on the spec
>> language, partly because rfc 3530 is known to have a few oversights in
>> the error listings.)
>>
>> I definitely appreciate people going through the pynfs tests and
>> investigating the results, but I don't want patch whose only
>> justification is that they quiet pynfs--we need to think about the
>> likely effect on real clients too.
> 
> Also, for example:
> 
>>> @@ -2234,8 +2234,12 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>>  			cstate->current_fh.fh_dentry->d_name.name);
>>>  
>>>  	status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0);
>>> -	if (status)
>>> +	if (status) {
>>> +		/* nfserr_symlink returned is inappropriate for OPEN_CONFIRM */
>>> +		if (status == nfserr_symlink)
>>> +			status = nfserr_inval;
>>>  		return status;
>>> +	}
> 
> open_confirm is done with the same filehandle that was returned from a
> previous OPEN.  But an OPEN should never return the filehandle for a
> symlink.  That means for us to reach this case, either the client or our
> filesystem has a very serious bug.  Therefore, I'm not convinced that
> getting the error return correct in this case is worth the trouble.

Agreed,Maybe the err will never be returned.It's even do not worth to
fix it,but people may continuing sending patchs to fix these errors...

Maybe we should think about a better solution.

> 
> --b.
> 
> By the way, I have some old notes on the pynfs tests, below; they may be
> wrong, or out of date, but perhaps they're of some use.

Great,They're of great help to me,Thank you very much.::)

> 
> 
> --fixme:
> 
> CID6: returning EXPIRED on OPEN with unconfirmed client, should return STALE.
> (Why?)
> 
> --bugs, but probably not important:
> 
> OPCF3a, LINK4a, LOOKP2a, SATT12a: These 4 operations don't seem to
> support NFS4ERR_SYMLINK, so we shouldn't be returning it.  This error
> appears to be intentionally just for LOOKUP and OPEN, probably to help
> implement O_NOFOLLOW or something.  It's fh_verify that's producing this
> error.  There are some special cases in nfs4proc.c that map this error
> to einval, but we should probably figure out some better way to deal
> with this than special casing every other fh_verify error return....
> 
> CR14: create of dir with / in the name should return BADNAME or BADCHAR, not
> INVAL.
> 
> CR13, LINK9, RNM11, CR13, LINK9, RNM11: We're returning the wrong error on use
> of '.' as a filename.
> 
> CR12, OPEN15: attempt to set acl on create should return
> NFS4ERR_ATTRNOTSUPP on fs that doesn't support acls, instead it returns
> OK.
> 
> --might care:
> 
> LOOK6, LOOK9, OPEN17, RDDR11, RDDR12: permitting operations on directories of
> mode 0.  This is probably a result of some logic that allows certain requests
> on files and directories whose permissions would otherwise deny it, if the
> requester is the owner of the file or directory.  I'm not sure this is a big
> deal; the client can enforce this requirement, and there's no big security
> hole as long as the owner could chmod the file anyway.
> 
> OPEN17: similar to above, but this on open of a file.  This seems odd.
> 
> 
> --probably don't care:
> 
> COMP6: should return RESOURCE not GARBAGE_ARGS on a compound with 150 ops.
> 
> WRT5: connection reset doing a big write.
> 
> LINK8, OPEN13, RM5, RNM8, RNM9, LOOK7: these result from our decision to
> continue treating filenames as opaque for now instead of insisting on utf-8 as
> the spec requires.
> 
> --bugs, out of scope for now:
> 
> SATT14: change attribute not affected by SETATTR(mode): this is another
> symptom of the ext2/3 time resolution problem.
> 
> RNM16: RENAME dir1 into existing, nonempty dir2 should return NFS4ERR_EXIST,
> instead got NFS4ERR_NOTEMPTY
> 
> 
> --I consider these dealt with:
> 
> SATT8: Andy thought we should be picky about something here where I thought we
> should just allow it; as a result I've been reluctant to either submit or drop
> the patch that make us less picky.  I've given up and dropped it.  Python
> should stop complaining.
> 
> LOCK8c: we're allowing nonzero lockseqid's in the open_to_lockowner struct; see
> discussion on this list last week.  This test should probably be removed or at
> least not run by default.
> 
> COMP3: Python is checking whether tags are utf-8 or not.  Could we just remove
> or disable this test?  It is true that the spec requires this, but it's a very
> silly requirement since tags are only debugging aids anyway.
> 
> 


-- 
Regards
Yang Hongyang
