Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sonic310-27.consmr.mail.gq1.yahoo.com ([98.137.69.153]:44269
        "EHLO sonic310-27.consmr.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752036AbeFAQWb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2018 12:22:31 -0400
Subject: Re: [PATCH 1/1] Fix memory leak in kernfs_security_xattr_set and
 kernfs_security_xattr_set
To: chandan.vn@samsung.com, Tejun Heo <tj@kernel.org>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        CPGS <cpgs@samsung.com>,
        Sireesha Talluri <sireesha.t@samsung.com>,
        Chris Wright <chrisw@sous-sol.org>,
        "linux-security-module@vger.kernel.org"
        <linux-security-module@vger.kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>
References: <1ced6bce-92cc-7e0c-fab4-0aaa3d03b82f@schaufler-ca.com>
 <1527758911-18610-1-git-send-email-chandan.vn@samsung.com>
 <20180531153943.GR1351649@devbig577.frc2.facebook.com>
 <4f00f9ae-3302-83b9-c083-d21ade380eb2@schaufler-ca.com>
 <20180531161107.GV1351649@devbig577.frc2.facebook.com>
 <CGME20180531092848epcas1p24b638ccd6da00f1e039bdb64de7e1a5b@epcms5p5>
 <20180601085609epcms5p5fefac0156a4816e9e48751211ab595ee@epcms5p5>
From: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <02d9878e-65bf-5de8-9658-cf0f692f358c@schaufler-ca.com>
Date: Fri, 1 Jun 2018 09:22:28 -0700
MIME-Version: 1.0
In-Reply-To: <20180601085609epcms5p5fefac0156a4816e9e48751211ab595ee@epcms5p5>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/1/2018 1:56 AM, CHANDAN VN wrote:
> Hi
>  
>
>> On 5/31/2018 9:11 AM, Tejun Heo wrote:
>>  On Thu, May 31, 2018 at 09:04:25AM -0700, Casey Schaufler wrote:
>>>>  On 5/31/2018 8:39 AM, Tejun Heo wrote:
>>>>>  (cc'ing more security folks and copying whole body)
>>>>>
>>>>>  So, I'm sure the patch fixes the memory leak but API wise it looks
>>>>>  super confusing.  Can security folks chime in here?  Is this the right
>>>>>  fix?
>>>>>  security_inode_getsecctx() provides a security context. Technically,
>>>>>  this is a data blob, although both provider provide a null terminated
>>>>>  string. security_inode_getsecurity(), on the other hand, provides a
>>>>>  string to match an attribute name. The former releases the security
>>>>>  context with security_release_secctx(), where the later releases the
>>>>>  string with kfree().
>>>>>
>>>>>  When the Smack hook smack_inode_getsecctx() was added in 2009
>>>>>  for use by labeled NFS the alloc value passed to
>>>>  smack_inode_getsecurity() was set incorrectly. This wasn't a
>>>>  major issue, since labeled NFS is a fringe case. When kernfs
>>>>  started using the hook, it became the issue you discovered.
>>>>
>>>>  The reason that we have all this confusion is that SELinux
>>>>  generates security contexts as needed, while Smack keeps them
>>>>  around all the time. Releasing an SELinux context frees memory,
>>>>  while releasing a Smack context is a null operation.
>>>  Any chance this detail can be hidden behind security api?  This looks
>>>  pretty error-prone, no?
>  
>>> It *is* hidden behind the security API. The problem is strictly
>>> within the Smack code, where the implementer of smack_inode_getsecctx()
>>> made an error.
> I agree that the fix can be done simply by using "false" for 
> smack_inode_getsecurity(), but what happens with kernfs_node_setsecdata()
> and smack_inode_notifysecctx(). kernfs_node_setsecdata() is probably ignorable
> but smack_inode_notifysecctx() is sending the "ctx" to smack_inode_setsecurity()
> and since "ctx" would be NULL because we used "false", smack_inode_setsecurity()
> becomes dummy.

Thank you for pointing this out. You're right, there's more
at issue here than changing the alloc flag will fix. I think
that calling smack_inode_getsecurity() from smack_inode_getsecctx()
is making the code more complicated than it needs to be. I will
have a patch shortly.


