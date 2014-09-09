Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oi0-f53.google.com ([209.85.218.53]:54953 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755198AbaIIC7J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 22:59:09 -0400
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSkHuw22tLecFmo+aRafMM3CXDME-tU_5xoWLgstEnEZw@mail.gmail.com>
References: <1408217806-25877-1-git-send-email-xiyou.wangcong@gmail.com>
	<87ppfvrdux.fsf@x220.int.ebiederm.org>
	<20140828014123.GF18016@ZenIV.linux.org.uk>
	<CAHQdGtSkHuw22tLecFmo+aRafMM3CXDME-tU_5xoWLgstEnEZw@mail.gmail.com>
Date: Mon, 8 Sep 2014 19:59:08 -0700
Message-ID: <CAM_iQpUfHGvHfC9Omew7QM-npbSNs67cmpEgZW_q_r6+qQfU4g@mail.gmail.com>
Subject: Re: [PATCH v2] nfs: fix kernel warning when removing proc entry
From: Cong Wang <xiyou.wangcong@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dan Aloni <dan@kernelim.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 8, 2014 at 4:54 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Wed, Aug 27, 2014 at 6:41 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>> On Tue, Aug 19, 2014 at 09:20:38PM -0700, Eric W. Biederman wrote:
>>> Cong Wang <xiyou.wangcong@gmail.com> writes:
>>>
>>> > I saw the following kernel warning:
>>>
>>> Cong thanks for finding and tracking this.  I was clearly asleep at the
>>> switch when I was testing my fix to the nfs client code :(
>>>
>>> I have applied this patch and will push it to Linus after it has a
>>> little bit to sit in linux-next.
>>
>>         Why does that code wank with one-by-one remove_proc_entry(), BTW?
>> remove_proc_subtree("nfsfs", net->proc_net) will take care of the whole pile
>> just fine, TYVM...  While we are it, there's no need to keep ->proc_nfsfs
>> at all - just have it in a local variable in nfs_fs_proc_net_init().
>
> Since nobody sent me an updated version with the remove_proc_subtree
> fix, I went ahead and edited the patch myself (see attachment). Cong,
> please let me know if you disagree with that change, otherwise, that
> will be the final patch sent upstream and Cc: stable # 3.4+.
>
> I'll schedule cleanup patches to make the same changes to the original
> nfs_fs_proc_exit() and nfs_fs_proc_init() and to remove (struct
> nfs_net)->proc_nfsfs for merging in 3.18.
>

Oops, I missed Al's reply and didn't know remove_proc_subtree() either.

Thanks for the update and it definitely looks good to me!
