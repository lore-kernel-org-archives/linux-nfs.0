From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] nfsd: permit unauthenticated stat of export root
Date: Thu, 07 Aug 2008 15:39:45 -0400
Message-ID: <489B4F81.8000204@redhat.com>
References: <20080807181148.GK18904@fieldses.org> <489B3DAC.5060004@redhat.com> <20080807191656.GL18904@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751512AbYHGTjs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2008 15:39:48 -0400
In-Reply-To: <20080807191656.GL18904@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Aug 07, 2008 at 02:23:40PM -0400, Peter Staubach wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> From: J. Bruce Fields <bfields@citi.umich.edu>
>>>
>>> RFC 2623 section 2.3.2 permits the server to bypass gss authentication
>>> checks for certain operations that a client may perform when mounting.
>>> In the case of a client that doesn't have some form of credentials
>>> available to it on boot, this allows it to perform the mount unattended.
>>> (Presumably real file access won't be needed until a user with
>>> credentials logs in.)
>>>
>>> Being slightly more lenient allows lots of old clients to access
>>> krb5-only exports, with the only loss being a small amount of
>>> information leaked about the root directory of the export.
>>>
>>> This affects on v2 and v3; v4 still requires authentication for all
>>> access.
>>>
>>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>> ---
>>>  fs/nfsd/nfs3proc.c        |    5 +++--
>>>  fs/nfsd/nfsfh.c           |   30 ++++++++++++++++++++----------
>>>  fs/nfsd/nfsproc.c         |    6 ++++--
>>>  fs/nfsd/vfs.c             |    4 ++--
>>>  include/linux/nfsd/nfsd.h |    3 ++-
>>>  5 files changed, 31 insertions(+), 17 deletions(-)
>>>
>>> I intend to submit this for 2.6.28
>>>
>>> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
>>> index 4d617ea..1419142 100644
>>> --- a/fs/nfsd/nfs3proc.c
>>> +++ b/fs/nfsd/nfs3proc.c
>>> @@ -530,7 +530,7 @@ nfsd3_proc_fsstat(struct svc_rqst * rqstp, struct nfsd_fhandle    *argp,
>>>  	dprintk("nfsd: FSSTAT(3)   %s\n",
>>>  				SVCFH_fmt(&argp->fh));
>>>  -	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats);
>>> +	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats, 0);
>>>  	fh_put(&argp->fh);
>>>  	RETURN_STATUS(nfserr);
>>>  }
>>> @@ -558,7 +558,8 @@ nfsd3_proc_fsinfo(struct svc_rqst * rqstp, struct nfsd_fhandle    *argp,
>>>  	resp->f_maxfilesize = ~(u32) 0;
>>>  	resp->f_properties = NFS3_FSF_DEFAULT;
>>>  -	nfserr = fh_verify(rqstp, &argp->fh, 0, NFSD_MAY_NOP);
>>> +	nfserr = fh_verify(rqstp, &argp->fh, 0,
>>> +			NFSD_MAY_NOP | NFSD_MAY_BYPASS_GSS_ON_ROOT);
>>>   	/* Check special features of the file system. May request
>>>  	 * different read/write sizes for file systems known to have
>>>   
>>>       
>> I would think that you might want to have nfsd3_proc_getattr()
>> in this list too.  Some clients may need to generate a GETATTR
>> if they need the attributes for the root node.
>>     
>
> Do you know of any? rfc 2623 makes it sound like those clients are out
> of luck.  And testing confirms that this patch is sufficient for the
> linux client, at least.

I believe that the Solaris client may.  I think that it may
use the attributes returned from the FSINFO call, if there
are any, to prevent the additional GETATTR, but this should
be tested.  It might also be interesting to test out a
readonly failover mount on the Solaris client to see what
behavior that that exhibits.

       ps
