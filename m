Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:48604 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195AbaIHU0V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 16:26:21 -0400
MIME-Version: 1.0
In-Reply-To: <20140908185039.GA1616@whiteoak.sf.office.twttr.net>
References: <1408217806-25877-1-git-send-email-xiyou.wangcong@gmail.com>
	<87ppfvrdux.fsf@x220.int.ebiederm.org>
	<20140908185039.GA1616@whiteoak.sf.office.twttr.net>
Date: Mon, 8 Sep 2014 13:26:20 -0700
Message-ID: <CAADnVQLTRq=GyCYFXUWGiRm=1hgi4s4kA4SS5rtVSCHHud1uTg@mail.gmail.com>
Subject: Re: [PATCH v2] nfs: fix kernel warning when removing proc entry
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Dan Aloni <dan@kernelim.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 8, 2014 at 11:50 AM, Matt Mullins <mmullins@twopensource.com> wrote:
> On Tue, Aug 19, 2014 at 09:20:38PM -0700, Eric W. Biederman wrote:
>> I have applied this patch and will push it to Linus after it has a
>> little bit to sit in linux-next.

what's the status of this patch?
It's rc4 already and I keep seeing it every boot:
[    7.730034] WARNING: CPU: 3 PID: 103 at ../fs/proc/generic.c:521
remove_proc_entry+0x1a4/0x1b0()
[    7.730036] remove_proc_entry: removing non-empty directory
'fs/nfsfs', leaking at least 'volumes'
[    7.730037] Modules linked in: ...
[    7.730063] CPU: 3 PID: 103 Comm: kworker/u8:15 Not tainted 3.17.0-rc4+ #196
