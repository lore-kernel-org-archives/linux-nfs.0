Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:16365 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932480AbcHJSWU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2016 14:22:20 -0400
Subject: Re: [lkp] [nfsd] b44061d0b9: BUG: Dentry
 ffff880027d7c540{i=1846f,n=0a} still in use (1) [unmount of btrfs vda]
To: Linus Torvalds <torvalds@linux-foundation.org>,
        kernel test robot <xiaolong.ye@intel.com>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>
References: <20160810053947.GG21941@yexl-desktop>
 <CA+55aFxdcG4y4zWTFFT8SekEtxsvx12P+e=11kTCFc=zS__bXQ@mail.gmail.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Josef Bacik <jbacik@fb.com>
Message-ID: <dc406145-b465-b7e9-e370-91910abb8e6a@fb.com>
Date: Wed, 10 Aug 2016 14:22:07 -0400
MIME-Version: 1.0
In-Reply-To: <CA+55aFxdcG4y4zWTFFT8SekEtxsvx12P+e=11kTCFc=zS__bXQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2016 02:06 PM, Linus Torvalds wrote:
> On Tue, Aug 9, 2016 at 10:39 PM, kernel test robot
> <xiaolong.ye@intel.com> wrote:
>>
>> [ 1537.558739] nfsd: last server has exited, flushing export cache
>> [ 1540.627795] BUG: Dentry ffff880027d7c540{i=1846f,n=0a}  still in use (1) [unmount of btrfs vda]
>> [ 1540.633915] ------------[ cut here ]------------
>> [ 1540.636551] WARNING: CPU: 0 PID: 20552 at fs/dcache.c:1474 umount_check+0x72/0x80
>
> Hmm. Adding Al and the btrfs people to the cc, and expanding the nfs
> list. Unlike the flakey-IO warning, this one sounds like a real issue.
> Whether it's some dentry leak by nfsd or a VFS or btrfs issue, I can't
> begin to guess. Al, ideas?
>
> More information in the original email on lkml.
>

I'm not subscribed to lkml and for some reason I can't find the original email 
in any of the lkml/linux-nfs archives.  Could you forward more of the details? 
Thanks,

Josef

