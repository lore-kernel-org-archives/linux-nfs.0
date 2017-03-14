Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33662 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751798AbdCNOpt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Mar 2017 10:45:49 -0400
Received: by mail-io0-f194.google.com with SMTP id f84so115202ioj.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Mar 2017 07:45:44 -0700 (PDT)
Subject: Re: some problems about nfs mount
To: Houlinfei <hou.linfei@h3c.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <3858597F7658604DB90E3F60F716249C4696C326@H3CMLB12-EX.srv.huawei-3com.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "neilb@suse.com" <neilb@suse.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <9eae7982-7c7c-163f-5af7-df84b74ec3a2@gmail.com>
Date: Tue, 14 Mar 2017 22:45:14 +0800
MIME-Version: 1.0
In-Reply-To: <3858597F7658604DB90E3F60F716249C4696C326@H3CMLB12-EX.srv.huawei-3com.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I get an Ubuntu 12.04.5 source (linux-source-3.13.0) and have a check on centos7,
(for I don't known how to build and install kernel on ubuntu).

I found the problem maybe fix by the following patch (Ubuntu 14.04 includes),

"NFSv4: test SECINFO RPC_AUTH_GSS pseudoflavors for support",
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/patch/?id=66b0686049

the following two patch needs apply with the above,
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/patch/?id=8445cd3528b
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/patch/?id=57bbe3d7c11

thanks,
Kinglong Mee

On 3/14/2017 16:47, Houlinfei wrote:
> hi Kinglong:
> At client,
> 
> # cat /proc/version
> Linux version 3.13.0-32-generic (buildd@phianna) (gcc version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #57~precise1-Ubuntu SMP Tue Jul 15 03:51:20 UTC 2014
> # cat /etc/issue
> Ubuntu 12.04.5 LTS \n \l
> 
> thanks,
> houlinfei
> 
> On 3/14/2017 13:41, Kinglong Mee wrote:
>> On 3/14/2017 11:52, Houlinfei wrote:
>>> hi Kinglong:
>>> There has no firewall. While my client system is Ubuntu 14.04, it's ok.
>>> There has problem on ubuntu12.04 system. But if I add a parameter sec=sys, it is also ok. Such as, #mount -t nfs -o sec=sys 193.168.70.26:/root/hh /mnt/uu
>>> But when my mount command line t is #mount -t nfs 193.168.70.26:/root/hh /mnt/uu   it fail.
>>> There is some client fail log:
>>
>> The ubuntu12.04 system contains an old kernel, the problem should be a bug in that kernel.
>> I don't have an old kernel as ubuntu12.04 system, so I don't check the code.
>>
>> Can you have a try with the following patch ?
>> Your can get more information from the comments in the patch.
>>
>> Commit 4580a92d4 ("NFS: Use server-recommended security flavor by default"),
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4580a92d4
>>
> 
> Sorry, please ignore the above comments.
> I don't think it's useful, I will find an ubuntu12.04 and have a check.
> 
> thanks,
> Kinglong Mee
> -------------------------------------------------------------------------------------------------------------------------------------
> 本邮件及其附件含有杭州华三通信技术有限公司的保密信息，仅限于发送给上面地址中列出
> 的个人或群组。禁止任何其他人以任何形式使用（包括但不限于全部或部分地泄露、复制、
> 或散发）本邮件中的信息。如果您错收了本邮件，请您立即电话或邮件通知发件人并删除本
> 邮件！
> This e-mail and its attachments contain confidential information from H3C, which is
> intended only for the person or entity whose address is listed above. Any use of the
> information contained herein in any way (including, but not limited to, total or partial
> disclosure, reproduction, or dissemination) by persons other than the intended
> recipient(s) is prohibited. If you receive this e-mail in error, please notify the sender
> by phone or email immediately and delete it!
> 
