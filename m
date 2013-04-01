Return-Path: linux-nfs-owner@vger.kernel.org
Received: from blv-mbsout-02.boeing.com ([130.76.32.232]:51336 "EHLO
	blv-mbsout-02.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492Ab3DANDu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Apr 2013 09:03:50 -0400
From: "Vu, Joseph" <joseph.vu@boeing.com>
To: Casey Schaufler <casey@schaufler-ca.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: David Quigley <dpquigl@davequigley.com>, Steve Dickson <steved@redhat.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: RE: [PATCH 13/14] NFSD: Server implementation of MAC Labeling
Date: Mon, 1 Apr 2013 12:54:34 +0000
Message-ID: <756D04455A661C4CA25DC5BA4902A7A722698B22@XCH-PHX-204.sw.nos.boeing.com>
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com>
 <1364478845-29796-14-git-send-email-SteveD@redhat.com>
 <20130328161444.GF7080@fieldses.org> <51550C03.1000107@davequigley.com>
 <20130329144050.GB22307@fieldses.org>
 <001ff69afd411b0318d7122bf07bd218@countercultured.net>
 <5155B0E3.9040108@schaufler-ca.com> <20130329184219.GG22307@fieldses.org>
 <5155F51E.8020603@schaufler-ca.com>
In-Reply-To: <5155F51E.8020603@schaufler-ca.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think 2k will do for a while. I think that in the long run it will come up short. I think the real question is whether NFS will remain viable long enough for it to matter. 

What is a good, and working alternative for NFS in term of SE label?


-----Original Message-----
From: owner-selinux@tycho.nsa.gov [mailto:owner-selinux@tycho.nsa.gov] On Behalf Of Casey Schaufler
Sent: Friday, March 29, 2013 3:10 PM
To: J. Bruce Fields
Cc: David Quigley; Steve Dickson; Trond Myklebust; J. Bruce Fields; David P. Quigley; Linux NFS list; Linux Security List; SELinux List; Casey Schaufler
Subject: Re: [PATCH 13/14] NFSD: Server implementation of MAC Labeling

On 3/29/2013 11:42 AM, J. Bruce Fields wrote:
> On Fri, Mar 29, 2013 at 08:18:59AM -0700, Casey Schaufler wrote:
>> On 3/29/2013 7:49 AM, David Quigley wrote:
>>> On 03/29/2013 10:40, J. Bruce Fields wrote:
>>>> On Thu, Mar 28, 2013 at 11:35:31PM -0400, Dave Quigley wrote:
>>>>> On 3/28/2013 12:14 PM, J. Bruce Fields wrote:
>>>>>> On Thu, Mar 28, 2013 at 09:54:04AM -0400, Steve Dickson wrote:
>>>>>>> From: David Quigley <dpquigl@davequigley.com>
>>>>>>>
>>>>>>> This patch adds the ability to encode and decode file labels on
>>>>> the server for
>>>>>>> the purpose of sending them to the client and also to process
>>>>> label change
>>>>>>> requests from the client.
>>>>>>>
>>>>>>> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
>>>>>>> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
>>>>>>> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
>>>>>>> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
>>>>>>> ---
>>>>>>>  fs/nfsd/nfs4proc.c |  41 +++++++++++++++++++  fs/nfsd/nfs4xdr.c  
>>>>>>> | 116
>>>>> ++++++++++++++++++++++++++++++++++++++++++++++++++---
>>>>>>>  fs/nfsd/nfsd.h     |   6 ++-
>>>>>>>  fs/nfsd/vfs.c      |  29 ++++++++++++++
>>>>>>>  fs/nfsd/vfs.h      |   2 +
>>>>>>>  fs/nfsd/xdr4.h     |   3 ++
>>>>>>>  6 files changed, 191 insertions(+), 6 deletions(-)
>>>>>>>
>>>>>>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c index 
>>>>>>> ae73175..bb17589 100644
>>>>>>> --- a/fs/nfsd/nfs4proc.c
>>>>>>> +++ b/fs/nfsd/nfs4proc.c
>>>>>>> @@ -42,6 +42,36 @@
>>>>>>>  #include "current_stateid.h"
>>>>>>>  #include "netns.h"
>>>>>>>
>>>>>>> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL #include 
>>>>>>> +<linux/security.h>
>>>>>>> +
>>>>>>> +static inline void
>>>>>>> +nfsd4_security_inode_setsecctx(struct svc_fh *resfh, struct
>>>>> nfs4_label *label, u32 *bmval)
>>>>>>> +{
>>>>>>> +    struct inode *inode = resfh->fh_dentry->d_inode;
>>>>>>> +    int status;
>>>>>>> +
>>>>>>> +    mutex_lock(&inode->i_mutex);
>>>>>>> +    status = security_inode_setsecctx(resfh->fh_dentry,
>>>>>>> +        label->label, label->len);
>>>>>>> +    mutex_unlock(&inode->i_mutex);
>>>>>>> +
>>>>>>> +    if (status)
>>>>>>> +        /*
>>>>>>> +         * We should probably fail the whole open at this point,
>>>>>>> +         * but we've already created or opened the file, so it's
>>>>>>> +         * too late; So this seems the least of evils:
>>>>>>> +         */
>>>>>>> +        bmval[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
>>>>>> Is there any way to avoid this?
>>>>>>
>>>>>> How does the vfs open code handle this?  It has to be able to set 
>>>>>> a security contexts atomically on open(O_CREAT), doesn't it?
>>>>>>
>>>>> I believe the way this is handled is that the inode is created and 
>>>>> labeled and then only after that is it bound to the namespace.
>>>>> Because of that ordering we can fail and release the inode without 
>>>>> it ever having a dentry in the namespace.
>>>> Grepping around....  Looks like that's done by 
>>>> security_inode_init_security(), from the filesystem's create method.
>>>>
>>>> So we'd need to be able to pass something down to there.
>>>>
>>>> Is the current client actually expected to use this?  (So are we 
>>>> going to see a lot of opens that set the label?)
>>>>
>>>> --b.
>>> I don't have all the code infront of me but we have a different hook 
>>> to do that. The call to nfsd4_security_inode_setsecctx is supposed 
>>> to be used from the setattr handlers to do the equivalent of a 
>>> setxattr on the file over NFS. The actual creation gets done with 
>>> something like security_dentry_init_security which should be in an 
>>> earlier patch. I'd have to look more clearly at the code to find 
>>> out. Also where did we come up with 128 for label length? The 
>>> SELinux code assumes a starting point of 255 and goes up from there 
>>> as needed. The MLS policies will definitely exceed a 128 byte label.
>> If anyone cares, Smack labels can (now) be 255 characters.
>> Also, when (if) we get multiple concurrent LSMs the "security 
>> context" may include information for more than one LSM. 128 bytes is 
>> going to look pretty tiny then.
>>
>> smack='com.corportation.service'selinux='system_u:object_r:bin_t:s0'
> OK.  We need a number.  2k?

Consider some of the kinds of attributes we are likely to see in the not to distant future:

Permitted access times, at around 100 bytes each.
Bell & LaPadula labels at 500 bytes each.
Signatures of various sizes and flavors.
HEPA restrictions

I think 2k will do for a while. I think that in the long run it will come up short. I think the real question is whether NFS will remain viable long enough for it to matter.

>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-security-module" in the body of a message to 
> majordomo@vger.kernel.org More majordomo info at  
> http://vger.kernel.org/majordomo-info.html
>


--
This message was distributed to subscribers of the selinux mailing list.
If you no longer wish to subscribe, send mail to majordomo@tycho.nsa.gov with the words "unsubscribe selinux" without quotes as the message.
