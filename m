Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:5005 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933734AbcHJSeV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2016 14:34:21 -0400
Subject: Re: [lkp] [nfsd] b44061d0b9: BUG: Dentry
 ffff880027d7c540{i=1846f,n=0a} still in use (1) [unmount of btrfs vda]
To: Linus Torvalds <torvalds@linux-foundation.org>
References: <20160810053947.GG21941@yexl-desktop>
 <CA+55aFxdcG4y4zWTFFT8SekEtxsvx12P+e=11kTCFc=zS__bXQ@mail.gmail.com>
 <dc406145-b465-b7e9-e370-91910abb8e6a@fb.com>
 <CA+55aFzdTMBc7f5=bQLRUtceu-Kg-MGmzWrAv1r96_ra8yutJA@mail.gmail.com>
CC: kernel test robot <xiaolong.ye@intel.com>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Josef Bacik <jbacik@fb.com>
Message-ID: <b7111dc6-a077-0100-1f99-2af09f126f73@fb.com>
Date: Wed, 10 Aug 2016 14:32:47 -0400
MIME-Version: 1.0
In-Reply-To: <CA+55aFzdTMBc7f5=bQLRUtceu-Kg-MGmzWrAv1r96_ra8yutJA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2016 02:25 PM, Linus Torvalds wrote:
> On Wed, Aug 10, 2016 at 11:22 AM, Josef Bacik <jbacik@fb.com> wrote:
>> On 08/10/2016 02:06 PM, Linus Torvalds wrote:
>>>
>>> More information in the original email on lkml.
>>
>> I'm not subscribed to lkml and for some reason I can't find the original
>> email in any of the lkml/linux-nfs archives.  Could you forward more of the
>> details?
>
> Done.
>

Looks like an NFS problem.  Before in the !resfhp->fh_dentry case we would do a 
lookup_one_len() and carry on.  Now we do the lookup_one_len(), call into 
nfsd_create_locked() and do a dget on resfhp->f_dentry, which from looks of it 
is the dentry we just did a lookup_one_len() on, so we have one more ref on the 
dentry than we did previously.  Thanks,

Josef

