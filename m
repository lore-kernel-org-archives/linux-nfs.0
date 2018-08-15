Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:40987 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1728213AbeHOHuE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Aug 2018 03:50:04 -0400
Subject: Re: xfstest generci/465 failed under all versions of NFS
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <ff080c90-e2e9-686f-9bcd-b6a4af8ac1a0@cn.fujitsu.com>
 <20180806192743.GA9158@fieldses.org>
From: xuhuan <xuhuan.fnst@cn.fujitsu.com>
Message-ID: <f766633c-868e-c52c-48b3-b1805022a87b@cn.fujitsu.com>
Date: Wed, 15 Aug 2018 12:57:38 +0800
MIME-Version: 1.0
In-Reply-To: <20180806192743.GA9158@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry.i sent it already some days ago,but i didn't
notice that the mail was not cc the nfs Mail list for
some reason. so i have to sent this one more time.

Maybe the send fail is because the picture i attached.
so this time i attach nothing.

On 08/07/2018 03:27 AM, J. Bruce Fields wrote:
> On Mon, Aug 06, 2018 at 05:29:33PM +0800, xuhuan wrote:
>> I test NFS in xfstest generic/465 useing kernel v4.18-rc6.
>> I tested it with all version of nfs ,and all got failed.
>>
>> This patch fixes a bug in the xfs filesystem.Prior to this patch,
>> generic/465 is failed under the xfs file system.
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ee70daaba82d70766d0723b743d9fdeb3b06102a
>>
>> Now, under the xfs file system, generic/465 is passed, but when I use
>> it to test NFS, while the server using the xfs file system, the test will still fail.
>> I think it is a nfs's bug.I donnot know where is it.
> generic/465 says "Test i_size is updated properly under dio read/write".
> So I guess it's doing some direct IO that appends to a file and then a
> stat to confirm that we get the new i_size?
>
> If this isn't working when run on an NFS filesystem, then I think either
> the client isn't asking the server for the new i_size, or maybe it's
> asking but getting a bad response.  The bad response might have the old
> i_size.  Or I wonder if the client would be confused if the server
> failed to update the change attribute (i_version) for some reason?
>
> Does this test fail when we export other filesystems?  Is the failure
> new, or has it always failed?

ext4 and xfs are both PASS now.
On the nfs,the failure is not new,it seems to be always failed.

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
For the generic/465 test of xfstest. I intercepted the tcpdump
 data in a single loop. (Sent a 1M file in the loop)

For the NFS file system, it is divided into 4 requests and is read
and written 4 times.For multi-threaded operations, these 4
read/write operations may cause competition, resulting in
incomplete content being read during a read operation.
(At one fail try, the read operation reads the contents 
of the file when the third page is written)

So, is the NFS file system not suitable for this test?


write       write       write        write
|aaaa.......|aaaa.......|aaaa........|aaaa.......|
^read       ^read       ^read        ^read       ^1M 


Fail
(There are many failure scenarios. This is only one of them)

|00000000000|aaaa.......|aaaa........|aaaa.......|
^read                   ^read       ^read        ^read       ^1M 


PASS
|00000000000|00000000000|00000000000|00000000000|
^read                   ^read                   ^read                 ^read                 ^1M 

PASS
|aaaa.......|aaaa.......|aaaa........|aaaa.......|
^read       ^read       ^read        ^read       ^1M 

Thanks
Xu
