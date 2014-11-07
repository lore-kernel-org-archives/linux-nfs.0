Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:29192 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752510AbaKGVCQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Nov 2014 16:02:16 -0500
Message-ID: <545D3356.2060900@Netapp.com>
Date: Fri, 7 Nov 2014 16:02:14 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 2/3] nfsd: Add ALLOCATE support
References: <1415389467-16547-1-git-send-email-Anna.Schumaker@Netapp.com> <1415389467-16547-3-git-send-email-Anna.Schumaker@Netapp.com> <20141107210115.GA5723@fieldses.org>
In-Reply-To: <20141107210115.GA5723@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/07/2014 04:01 PM, J. Bruce Fields wrote:
> On Fri, Nov 07, 2014 at 02:44:26PM -0500, Anna.Schumaker@netapp.com wrote:
>> @@ -533,6 +534,28 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>  }
>>  #endif
>>  
>> +__be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
>> +			   struct file *file, loff_t offset, loff_t len,
>> +			   int flags)
>> +{
>> +	__be32 err;
>> +	int error;
>> +
>> +	if (!S_ISREG(file_inode(file)->i_mode))
>> +		return nfserr_inval;
>> +
>> +	err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry, NFSD_MAY_WRITE);
>> +	if (err)
>> +		return err;
>> +
>> +	error = vfs_fallocate(file, flags, offset, len);
>> +	if (!error)
>> +		error = commit_metadata(fhp);
>> +
>> +	if (error == -ENODEV)
>> +		return nfserr_inval;
> 
> 
> I don't think we need this check any more.
> 
> I'll just remove it myself as I apply if there's no objection.

Right!  Thanks for the reminder, I have no objections if you remove it :)

Anna
> 
> --b.
> 

