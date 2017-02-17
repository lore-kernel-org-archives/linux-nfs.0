Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36364 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934861AbdBQVKq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Feb 2017 16:10:46 -0500
Received: by mail-io0-f180.google.com with SMTP id j13so1783963iod.3
        for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2017 13:10:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170217200253.GI10894@fieldses.org>
References: <BLUPR06MB54767D9B4746E210D176C3AE1580@BLUPR06MB547.namprd06.prod.outlook.com>
 <20170217200253.GI10894@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 17 Feb 2017 16:10:45 -0500
Message-ID: <CAN-5tyGF8z=k6hk+Xbnh+_mWAiW_ywNnYR01YiOBVBRFzcyXUw@mail.gmail.com>
Subject: Re: Question about NFSv4.2 server-side copy implementation
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Mora, Jorge" <Jorge.Mora@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 17, 2017 at 3:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Feb 14, 2017 at 08:07:48PM +0000, Mora, Jorge wrote:
>> I can understand failing with NFS4ERR_INVAL when the source offset is beyond the end of the file,
>> but do you think failing with NFS4ERR_INVAL is too strict when the source offset plus the count is beyond the end of the file?
>> What is the rationalization for failing on this specific instance?
>> Why not return a short copy instead?
>> Can the COPY return a count less than what it requested (a short copy)?
>>
>> As of right now, the implementation on the Linux server adheres to the spec
>
> That's weird, do you have network traces showing that, or is it possible
> the EINVAL is happening on the client side?
>
> From a quick look at the server code I can't see where it would be
> generating that EINVAL, but I haven't tested this case and I could be
> overlooking something....
>

I think the current upstream COPY does not fail with EINVAL. The new
code that Jorge was testing does adhere to the spec and fails with
EINVAL.

Bruce, it looks to me that current upstream CLONE in this situation
will return EINVAL (I see that on the network trace since the client
will first try to do CLONE and if it can't it'll do COPY).

But we are trying to get some consistency in errors.


> --b.
>
>> but copy_file_range succeeds
>>
>> when it is called against the local file system, NFSv4.x or NFSv3.
>> For the local file system, NFSv4.x or NFSv3 copy_file_range falls back to regular copy by
>> reading from the source file and then writing to the destination file but I do believe the
>> syscall should be consistent regardless of the underlying file system.
>>
>>
>> --Jorge
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
