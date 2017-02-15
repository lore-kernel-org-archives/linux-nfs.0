Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34121 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751448AbdBOKgu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2017 05:36:50 -0500
Received: by mail-io0-f194.google.com with SMTP id c80so11875200iod.1
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2017 02:36:50 -0800 (PST)
Subject: Re: Question about NFSv4.2 server-side copy implementation
To: "Mora, Jorge" <Jorge.Mora@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <BLUPR06MB54767D9B4746E210D176C3AE1580@BLUPR06MB547.namprd06.prod.outlook.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <f186e424-5050-4651-6621-7ccc3688a49e@gmail.com>
Date: Wed, 15 Feb 2017 18:36:39 +0800
MIME-Version: 1.0
In-Reply-To: <BLUPR06MB54767D9B4746E210D176C3AE1580@BLUPR06MB547.namprd06.prod.outlook.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/15/2017 04:07, Mora, Jorge wrote:
> Hello,
>  
> The NFSv4.2 spec (RFC 7862) on section 15.2.3 (COPY description) says the following:
>  
> If the source offset or the source offset plus count is greater than
> the size of the source file, the operation MUST fail with
> NFS4ERR_INVAL.
>  
> I can understand failing with NFS4ERR_INVAL when the source offset is beyond the end of the file,

Yes, that's right.

> but do you think failing with NFS4ERR_INVAL is too strict when the source offset plus the count is beyond the end of the file?
> What is the rationalization for failing on this specific instance?
> Why not return a short copy instead?

The man-pages of copy_file_range description as,

       EINVAL Requested range extends beyond the end of the  source  file;  or
              the flags argument is not 0.

So, the specific instance you said isn't allowed.

> Can the COPY return a count less than what it requested (a short copy)?

Yes, the return value of copy_file_range is,

RETURN VALUE
       Upon successful completion, copy_file_range() will return the number of
       bytes copied between files.  This could be less than the length  origi‐
       nally requested.

>  
> As of right now, the implementation on the Linux server adheres to the spec but copy_file_range succeeds
> when it is called against the local file system, NFSv4.x or NFSv3.

NFSv3 doesn't support copy_file_range, and only NFSv4.2 supports copy_file_range.

> For the local file system, NFSv4.x or NFSv3 copy_file_range falls back to regular copy by
> reading from the source file and then writing to the destination file but I do believe the
> syscall should be consistent regardless of the underlying file system.
>  
>  
> --Jorge
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
