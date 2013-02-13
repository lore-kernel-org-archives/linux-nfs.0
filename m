Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757125Ab3BMAas (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 19:30:48 -0500
Message-ID: <511ADEB2.8030108@RedHat.com>
Date: Tue, 12 Feb 2013 19:30:42 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 06/15] NFSv4: Introduce new label structure
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com> <1360327163-20360-7-git-send-email-SteveD@redhat.com> <20130212220741.GJ10267@fieldses.org> <4FA345DA4F4AE44899BD2B03EEEC2FA91F3CE55C@sacexcmbx05-prd.hq.netapp.com> <20130212223226.GL10267@fieldses.org> <4FA345DA4F4AE44899BD2B03EEEC2FA91F3CE58F@sacexcmbx05-prd.hq.netapp.com> <20130212230623.GO10267@fieldses.org>
In-Reply-To: <20130212230623.GO10267@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/02/13 18:06, J. Bruce Fields wrote:
> On Tue, Feb 12, 2013 at 10:40:46PM +0000, Myklebust, Trond wrote:
>> On Tue, 2013-02-12 at 17:32 -0500, J. Bruce Fields wrote:
>>> On Tue, Feb 12, 2013 at 10:28:16PM +0000, Myklebust, Trond wrote:
>>>> On Tue, 2013-02-12 at 17:07 -0500, J. Bruce Fields wrote:
>>>>> On Fri, Feb 08, 2013 at 07:39:14AM -0500, Steve Dickson wrote:
>>>>>> From: David Quigley <dpquigl@davequigley.com>
>>>>>>
>>>>>> In order to mimic the way that NFSv4 ACLs are implemented we have created a
>>>>>> structure to be used to pass label data up and down the call chain. This patch
>>>>>> adds the new structure and new members to the required NFSv4 call structures.
>>>>>>
>>>>>> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
>>>>>> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
>>>>>> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
>>>>>> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
>>>>>> ---
>>>>>>  fs/nfs/inode.c            | 33 +++++++++++++++++++++++++++++++++
>>>>>>  include/linux/nfs4.h      |  7 +++++++
>>>>>>  include/linux/nfs_fs.h    | 17 +++++++++++++++++
>>>>>>  include/linux/nfs_xdr.h   | 21 +++++++++++++++++++++
>>>>>>  include/uapi/linux/nfs4.h |  2 +-
>>>>>>  5 files changed, 79 insertions(+), 1 deletion(-)
>>>>>>
>>>>>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>>>>>> index ebeb94c..8d5f01b 100644
>>>>>> --- a/fs/nfs/inode.c
>>>>>> +++ b/fs/nfs/inode.c
>>>>>> @@ -255,6 +255,39 @@ nfs_init_locked(struct inode *inode, void *opaque)
>>>>>>  	return 0;
>>>>>>  }
>>>>>>  
>>>>>> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
>>>>>> +struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags)
>>>>>> +{
>>>>>> +	struct nfs4_label *label = NULL;
>>>>>> +
>>>>>> +	if (!(server->caps & NFS_CAP_SECURITY_LABEL))
>>>>>> +		return label;
>>>>>> +
>>>>>> +	label = kzalloc(NFS4_MAXLABELLEN, flags);
>>>>>> +	if (label == NULL)
>>>>>> +		return ERR_PTR(-ENOMEM);
>>>>>> +
>>>>>> +	label->label = (char *)(label + 1);
>>>>>> +	label->len = NFS4_MAXLABELLEN;
>>>>>
>>>>> If you're expecting to be able to store up to NFS4_MAXLABELLEN of data
>>>>> after the end of the struct, then you want:
>>>>>
>>>>> 	label = kzalloc(sizeof(struct nfs4_label) + NFS4_MAXLABELLEN, flags);
>>>>
>>>> Sigh... No.
>>>>
>>>> I keep telling Steve that the 'label' needs to be defined as an array,
>>>
>>> Yeah, I know, he said in 0/15 that he couldn't do that, so I've been
>>> reading through these on the assumption I'll find out why not at some
>>> point....  (Still not seeing it, though.)
>>
>> It only makes sense to define label->label as a pointer if you need to
>> change the pointer value at some time. However, if that is the case,
>> then why allocate the struct nfs4_label and label string as a single
>> memory block? It would make more sense to allocate them separately so
>> that you can free the old label storage after you change the pointer.
> 
> nfs4_get_security_label() in a later patch is indeed using some
> passed-in storage instead, but I'm not sure it's doing it correctly.
Exactly, this is the interface where I'm thinking it makes sense to
keep label->label a pointer.

steved.

> 
> It would seem simpler to pick either inline or separate storage and
> stick with it throughout.
> 
> I'd be inclined to favor inline even if it means larger allocations than
> necessary or an extra copy.  Just because it seems harder to mess up.
> 
> --b.
> 
