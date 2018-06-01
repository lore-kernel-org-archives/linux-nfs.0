Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sonic306-26.consmr.mail.gq1.yahoo.com ([98.137.68.89]:42785
        "EHLO sonic306-26.consmr.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752594AbeFAQlm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2018 12:41:42 -0400
Subject: Re: [PATCH 1/1] Fix memory leak in kernfs_security_xattr_set and
 kernfs_security_xattr_set
To: chandan.vn@samsung.com,
        "linux-security-module@vger.kernel.org"
        <linux-security-module@vger.kernel.org>
Cc: Tejun Heo <tj@kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        CPGS <cpgs@samsung.com>,
        Sireesha Talluri <sireesha.t@samsung.com>,
        Chris Wright <chrisw@sous-sol.org>,
        Casey Schaufler <casey@schaufler-ca.com>
References: <02d9878e-65bf-5de8-9658-cf0f692f358c@schaufler-ca.com>
 <1ced6bce-92cc-7e0c-fab4-0aaa3d03b82f@schaufler-ca.com>
 <1527758911-18610-1-git-send-email-chandan.vn@samsung.com>
 <20180531153943.GR1351649@devbig577.frc2.facebook.com>
 <4f00f9ae-3302-83b9-c083-d21ade380eb2@schaufler-ca.com>
 <20180531161107.GV1351649@devbig577.frc2.facebook.com>
 <20180601085609epcms5p5fefac0156a4816e9e48751211ab595ee@epcms5p5>
 <CGME20180531092848epcas1p24b638ccd6da00f1e039bdb64de7e1a5b@epcms5p7>
 <20180601162913epcms5p7737f5b4376d8865af1eae119aa866550@epcms5p7>
From: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <5b0b157a-0e8c-d8f5-901e-836d545a8e4c@schaufler-ca.com>
Date: Fri, 1 Jun 2018 09:41:39 -0700
MIME-Version: 1.0
In-Reply-To: <20180601162913epcms5p7737f5b4376d8865af1eae119aa866550@epcms5p7>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/1/2018 9:29 AM, CHANDAN VN wrote:
>>>  I agree that the fix can be done simply by using "false" for 
>>>  smack_inode_getsecurity(), but what happens with kernfs_node_setsecdata()
>>>  and smack_inode_notifysecctx(). kernfs_node_setsecdata() is probably ignorable
>>>  but smack_inode_notifysecctx() is sending the "ctx" to smack_inode_setsecurity()
>>>  and since "ctx" would be NULL because we used "false", smack_inode_setsecurity()
>>>  becomes dummy.
>  
>> Thank you for pointing this out. You're right, there's more
>> at issue here than changing the alloc flag will fix. I think
>> that calling smack_inode_getsecurity() from smack_inode_getsecctx()
>> is making the code more complicated than it needs to be. I will
>> have a patch shortly.
> If you think the patch would take time or is complicated, I suggest that the kfree() fix should go
> to fix the leaks for now.

Heavens no! The patch is very simple. I'm building a kernel with
it now, and should have it tested and posted within a few hours.
The implementation of smack_inode_getsecctx() that's there is
understandable, but wrong. There's a much better way to do the
job.

