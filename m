Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36922 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940AbaICAQo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 20:16:44 -0400
Received: by mail-pd0-f182.google.com with SMTP id fp1so9710878pdb.41
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 17:16:44 -0700 (PDT)
Message-ID: <54065DDC.7080302@gmail.com>
Date: Wed, 03 Sep 2014 08:16:28 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/6] NFSD: Put file after ima_file_check fail in nfsd_open()
References: <5405CFE4.9060407@gmail.com> <20140902155755.GA14472@infradead.org>
In-Reply-To: <20140902155755.GA14472@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/2/2014 23:57, Christoph Hellwig wrote:
>> +	file = dentry_open(&path, flags, current_cred());
>> +	if (IS_ERR(file)) {
>> +		host_err = PTR_ERR(file);
>>  	} else {
> 
> The is_err case should have a
> 
> 	goto out_nfserr;
> 
> which would allow you to drop the following indentation if you
> change the whole function anyway.
> 
>>  		if (may_flags & NFSD_MAY_64BIT_COOKIE)
>> -			(*filp)->f_mode |= FMODE_64BITHASH;
>> +			(file)->f_mode |= FMODE_64BITHASH;
>>  		else
>> -			(*filp)->f_mode |= FMODE_32BITHASH;
>> +			(file)->f_mode |= FMODE_32BITHASH;
> 
> no need for the braces around file here.
> 

Thanks for your review.
A new version of this patch has be sent.

thanks,
Kinglong Mee
