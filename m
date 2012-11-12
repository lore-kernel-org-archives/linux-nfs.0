Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:50282 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753864Ab2KLQxQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 11:53:16 -0500
Message-ID: <50A12979.3040902@davequigley.com>
Date: Mon, 12 Nov 2012 11:53:13 -0500
From: "David P. Quigley" <selinux@davequigley.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: David Quigley <dpquigl@davequigley.com>, trond.myklebust@netapp.com,
        sds@tycho.nsa.gov, linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        "Matthew N. Dodd" <Matthew.Dodd@sparta.com>,
        Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>,
        Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>,
        Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
Subject: Re: [PATCH 07/13] NFSv4: Introduce new label structure
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <1352700947-3915-8-git-send-email-dpquigl@davequigley.com> <20121112151314.GG30713@fieldses.org> <50A116A8.20105@davequigley.com> <20121112160523.GJ30713@fieldses.org>
In-Reply-To: <20121112160523.GJ30713@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2012 11:05 AM, J. Bruce Fields wrote:
> On Mon, Nov 12, 2012 at 10:32:56AM -0500, David P. Quigley wrote:
>> On 11/12/2012 10:13 AM, J. Bruce Fields wrote:
>>> On Mon, Nov 12, 2012 at 01:15:41AM -0500, David Quigley wrote:
>>>> From: David Quigley<dpquigl@davequigley.com>
>>>>
>>>> In order to mimic the way that NFSv4 ACLs are implemented we have created a
>>>> structure to be used to pass label data up and down the call chain. This patch
>>>> adds the new structure and new members to the required NFSv4 call structures.
>>>>
>>>> Signed-off-by: Matthew N. Dodd<Matthew.Dodd@sparta.com>
>>>> Signed-off-by: Miguel Rodel Felipe<Rodel_FM@dsi.a-star.edu.sg>
>>>> Signed-off-by: Phua Eu Gene<PHUA_Eu_Gene@dsi.a-star.edu.sg>
>>>> Signed-off-by: Khin Mi Mi Aung<Mi_Mi_AUNG@dsi.a-star.edu.sg>
>>>> Signed-off-by: David Quigley<dpquigl@davequigley.com>
>>>> ---
>>>>   fs/nfs/inode.c          | 40 ++++++++++++++++++++++++++++++++++++++++
>>>>   fs/nfsd/xdr4.h          |  3 +++
>>>>   include/linux/nfs4.h    |  8 ++++++++
>>>>   include/linux/nfs_fs.h  | 14 ++++++++++++++
>>>>   include/linux/nfs_xdr.h | 20 ++++++++++++++++++++
>>>>   5 files changed, 85 insertions(+)
>>>>
>>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>>> index 5c7325c..0963ad9 100644
>>>> --- a/fs/nfs/inode.c
>>>> +++ b/fs/nfs/inode.c
>>>> @@ -246,6 +246,46 @@ nfs_init_locked(struct inode *inode, void *opaque)
>>>>   	return 0;
>>>>   }
>>>>
>>>> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
>>>> +struct nfs4_label *nfs4_label_alloc(gfp_t flags)
>>>> +{
>>>> +	struct nfs4_label *label = NULL;
>>>> +
>>>> +	label = kzalloc(sizeof(struct nfs4_label) + NFS4_MAXLABELLEN, flags);
>>> NFS4_MAXLABELLEN is 4096, but we usually try to avoid allocating more
>>> than that in a single allocation.
>> Should we make this smaller? I figured a page would be a good upper bound.
> If we could make it small enough so that the above fits in 4096 bytes
> that would be easier.
>
> (What does the protocol say?  On a quick glance it doesn't seem to
> impose a limit.)

The spec doesn't limit the size of a label but we thought that a page 
would be good. We can make it 4095 to ensure that it will always be in a 
page incase a null terminator is added. I believe someone mentioned this 
in the past I'm not sure why it didn't make its way in. We initially had 
something much larger but Trond chimed in and said that if its larger 
than a page something is wrong so we lowered it.

>
>>>> +	label->label = (void *)(label + 1);
>>>> +	label->len = NFS4_MAXLABELLEN;
>>>> +	/* 0 is the null format meaning that the data is not to be translated */
>>>> +	label->lfs = 0;
>>>> +	label->pi = 0;
>>> What's "pi"?
>>>
>>> --b.
>> In the LFS document we talk about how a policy identifier is a
>> recommended field. It isn't implemented yet as we're setting both
>> the LFS and the PI to 0 but I added it for when we put the LFS
>> mapping daemon in next. The idea is that even though we have a label
>> and we specify the format with the LFS we need to identify what
>> version of policy it is so we can ensure that the actual meaning of
>> a value is correct.
> And, my bad, this is in the spec--sorry, I need to go study it.
>
> --b.
>

Its ok. It's been in the works so long its hard to keep track of it all.
