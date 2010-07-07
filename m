Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:30343 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753534Ab0GGRoG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 13:44:06 -0400
Message-ID: <4C34BC77.4040906@oracle.com>
Date: Wed, 07 Jul 2010 13:42:15 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Casey Schaufler <casey@schaufler-ca.com>
CC: "David P. Quigley" <dpquigl@tycho.nsa.gov>, hch@infradead.org,
        viro@zeniv.linux.org.uk, sds@tycho.nsa.gov, matthew.dodd@sparta.com,
        trond.myklebust@fys.uio.no, bfields@fieldses.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/10] NFSv4: Introduce new label structure
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov> <1278513086-23964-8-git-send-email-dpquigl@tycho.nsa.gov> <4C34A4F1.3060708@oracle.com> <4C34A9A2.4080308@schaufler-ca.com>
In-Reply-To: <4C34A9A2.4080308@schaufler-ca.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/ 7/10 12:21 PM, Casey Schaufler wrote:
> Chuck Lever wrote:
>> My comments below apply to the other NFS client patches as well.  This
>> seemed like the right one to use for code examples.
>>
>> On 07/ 7/10 10:31 AM, David P. Quigley wrote:

   [ ... snipped ... ]

>>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>>> index a2abd1a..c512a0c 100644
>>> --- a/include/linux/nfs4.h
>>> +++ b/include/linux/nfs4.h
>>> @@ -167,6 +167,13 @@ struct nfs4_acl {
>>>        struct nfs4_ace    aces[0];
>>>    };
>>>
>>> +struct nfs4_label {
>>> +    void        *label;
>>> +    u32        len;
>>> +    uint32_t    lfs;
>>> +};
>>
>> If we have support for NFS labels in NFSv3, would we also use struct
>> nfs4_label?
>>
>> It seems to me you want something more generic, just like nfs_fh or
>> nfs_fattr, to represent these.  Over time, I'm guessing label support
>> won't be tied to a specific NFS version.  And, you are passing these
>> around in the generic NFS functions (for post-op updates and inode
>> revalidation, and what not).
>>
>> Can I recommend "struct nfs_seclabel" instead?  Then have
>> nfs_seclabel_alloc() and nfs_seclabel_free().
>
> Security has been the primary consumer of labels to date, but
> the xattr concept has always been envisioned as useful in many
> ways. That, and people have so many different views on what is
> and isn't security and whether it is good or evil that you are
> asking to limit the value if you tie "security" to the names.
> Plus, it adds unnecessary characters.

My main point is that the "nfs4" prefix is probably not optimal in the 
long run.  It seems to me that these labels are of generic use in the 
NFS client, and not necessarily specific to version 4.
