Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:59160 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757596Ab2K3NRh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2012 08:17:37 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Fri, 30 Nov 2012 08:17:35 -0500
From: David Quigley <dpquigl@davequigley.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Casey Schaufler <casey@schaufler-ca.com>, <trond.myklebust@netapp.com>,
        <sds@tycho.nsa.gov>, <linux-nfs@vger.kernel.org>,
        <selinux@tycho.nsa.gov>, <linux-security-module@vger.kernel.org>
Subject: Re: Labeled NFS [v5]
In-Reply-To: <607a8005d6c33a19c53b5ede29d81ef5@countercultured.net>
References: <50AC4A7A.6010208@davequigley.com>
 <50B65E7E.4030607@schaufler-ca.com> <50B6B706.1010002@davequigley.com>
 <50B6C398.90002@schaufler-ca.com> <50B7E189.80200@schaufler-ca.com>
 <d0817140372d745df0b4952b796610f2@countercultured.net>
 <50B7FEFB.30109@schaufler-ca.com>
 <579e850139bd3d5a0c9155270d5d9fbe@countercultured.net>
 <50B810D2.2000401@schaufler-ca.com>
 <3ea3f70e0a5cdb99f1594019b7bd619d@countercultured.net>
 <20121130121437.GC614@fieldses.org>
 <607a8005d6c33a19c53b5ede29d81ef5@countercultured.net>
Message-ID: <5170c3bd8900c36b372217af96e5e764@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/30/2012 07:57, David Quigley wrote:
> On 11/30/2012 07:14, J. Bruce Fields wrote:
>> On Thu, Nov 29, 2012 at 09:02:49PM -0500, David Quigley wrote:
>>> On 11/29/2012 20:50, Casey Schaufler wrote:
>>> >On 11/29/2012 4:46 PM, David Quigley wrote:
>>> >>On 11/29/2012 19:34, Casey Schaufler wrote:
>>> >>>I would think that were it not for the case that access is 
>>> denied
>>> >>>and I get an audit record for nfsd that reports a subject
>>> >>>label of "_"
>>> >>>(which is correct for nfsd but not the process attempting
>>> >>>access) and
>>> >>>an object label of "WhooHoo", which is correct. The server side
>>> >>>looks like it might be working right, given the information that 
>>> it
>>> >>>has.
>>> >>>
>>> >>
>>> >>Ok so this is the problem. nfsd is a kernel thread I believe. In
>>> >>SELinux land it has the type kernel_t which is all powerful. We
>>> >>don't
>>> >>have client label transport yet (That requires RPCSECGSSv3). Is
>>> >>there
>>> >>a way you can have that kernel thread running as a type that has
>>> >>access to everything?
>>> >
>>> >That would be having CAP_MAC_ADMIN and CAP_MAC_OVERRIDE in 
>>> Smackese.
>>> >Looking at /proc/<pid-of-nfsd>/status we see CapEff of fff...fff
>>> >which
>>> >is to say, all capabilities.
>>> >
>>>
>>> Hmm thats interesting then. You could try using rpcdebug -m nfsd to
>>> turn on some of the debugging to look around the internals and
>>> figure out whats going on. If you pass -v it will give you all of
>>> the potential flags.
>>>
>>> >
>>> >>I think that is the current problem. Which makes perfect sense. 
>>> If
>>> >>your kernel threads don't get started with max privilege then the
>>> >>server would be denied access on all of the file attributes and
>>> >>wouldn't be able to ship it over the wire properly.
>>> >
>>> >OK. I haven't had to do anything with kernel threads so far.
>>> >Where is NFS setting these up? Poking around fs/nfsd looks like
>>> >the place, but I haven't seen anything there that makes it look
>>> >like they would be running without capabilities. Clearly, that's
>>> >what I'm seeing. It looks as if the credential of nfsd does not
>>> >match what /proc reports. Bother.
>>> >
>>>
>>> I'm not entirely sure whats up either. If you want to look for the
>>> NFSd threads they are in fs/nfsd/nfssvc.c. The main function starts
>>> on line 487.
>>
>> I'm not following the discussion, but: maybe you want to look at
>> fs/nfsd/auth.c:nfsd_setuser() ?  In particular, the
>> cap_{drop/raise}_nfsd_set() calls at the end.
>>
>> --b.
>
>
> I'm not as familiar with the capabilities code as Casey is so I'll
> leave this ball in his court. I think you are correct though and the
> problem is that NFSd is dropping and raising caps and we need to make
> sure that MAC_ADMIN and MAC_OVERRIDE is in there in the SMACK case.
>
> --
> This message was distributed to subscribers of the selinux mailing 
> list.
> If you no longer wish to subscribe, send mail to 
> majordomo@tycho.nsa.gov with
> the words "unsubscribe selinux" without quotes as the message.


I think I found the offending code. I can't test it for a while so 
hopefully Casey can.

In include/linux/capability.h we have the following defines


# define CAP_FS_MASK_B0     (CAP_TO_MASK(CAP_CHOWN)             \
                             | CAP_TO_MASK(CAP_MKNOD)            \
                             | CAP_TO_MASK(CAP_DAC_OVERRIDE)     \
                             | CAP_TO_MASK(CAP_DAC_READ_SEARCH)  \
                             | CAP_TO_MASK(CAP_FOWNER)           \
                             | CAP_TO_MASK(CAP_FSETID))

# define CAP_FS_MASK_B1     (CAP_TO_MASK(CAP_MAC_OVERRIDE))

#if _KERNEL_CAPABILITY_U32S != 2
# error Fix up hand-coded capability macro initializers
#else /* HAND-CODED capability initializers */

# define CAP_EMPTY_SET    ((kernel_cap_t){{ 0, 0 }})
# define CAP_FULL_SET     ((kernel_cap_t){{ ~0, ~0 }})
# define CAP_FS_SET       ((kernel_cap_t){{ CAP_FS_MASK_B0 \
                                     | CAP_TO_MASK(CAP_LINUX_IMMUTABLE), 
\
                                     CAP_FS_MASK_B1 } })
# define CAP_NFSD_SET     ((kernel_cap_t){{ CAP_FS_MASK_B0 \
                                     | CAP_TO_MASK(CAP_SYS_RESOURCE), \
                                     CAP_FS_MASK_B1 } })

So raise and drop nfsd caps uses CAP_NFSD_SET. In CAP_NFSD_SET we have 
CAP_MAC_OVERRIDE but we don't have CAP_MAC_ADMIN. I think maybe if we 
had both then Casey should be able to use the code with SMACK. However 
I'm not sure what implications this has for every other LSM. Honestly 
I'm not sure if we use either of those caps for SELinux at all (I think 
we ignore them completely).


Maybe if CAP_FS_MASK_B1 was like this it would work.

# define CAP_FS_MASK_B1     (CAP_TO_MASK(CAP_MAC_OVERRIDE)    \
)



