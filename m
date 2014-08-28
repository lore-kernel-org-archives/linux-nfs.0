Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:46875 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933884AbaH1CGO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2014 22:06:14 -0400
Date: Thu, 28 Aug 2014 02:41:23 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Dan Aloni <dan@kernelim.com>
Subject: Re: [PATCH v2] nfs: fix kernel warning when removing proc entry
Message-ID: <20140828014123.GF18016@ZenIV.linux.org.uk>
References: <1408217806-25877-1-git-send-email-xiyou.wangcong@gmail.com>
 <87ppfvrdux.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87ppfvrdux.fsf@x220.int.ebiederm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 19, 2014 at 09:20:38PM -0700, Eric W. Biederman wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
> 
> > I saw the following kernel warning:
> 
> Cong thanks for finding and tracking this.  I was clearly asleep at the
> switch when I was testing my fix to the nfs client code :(
> 
> I have applied this patch and will push it to Linus after it has a
> little bit to sit in linux-next.

	Why does that code wank with one-by-one remove_proc_entry(), BTW?
remove_proc_subtree("nfsfs", net->proc_net) will take care of the whole pile
just fine, TYVM...  While we are it, there's no need to keep ->proc_nfsfs
at all - just have it in a local variable in nfs_fs_proc_net_init().
