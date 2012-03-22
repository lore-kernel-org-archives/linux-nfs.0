Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab2CVOud (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 10:50:33 -0400
Date: Thu, 22 Mar 2012 15:42:46 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, keyrings@linux-nfs.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <tj@kernel.org>,
        David Rientjes <rientjes@google.com>
Subject: Re: [RFC 4/4] {RFC} kmod.c: Add new call_usermodehelper_timeout()
	API
Message-ID: <20120322144246.GA13873@redhat.com>
References: <4F691059.30405@panasas.com> <4F691383.5040506@panasas.com> <4F6A92FC.6060702@panasas.com> <20120322142758.GA12370@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120322142758.GA12370@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

BTW,

On 03/22, Oleg Nesterov wrote:
>
> In any case. I do not know why do we need timeout, but this is
> orthogonal to KILLABLE. Please redo your patches on top of -mm
> tree? Please note that in this case the change becomes trivial.

I have found 1-3 on marc.info, they look fine.

But 2/4 is not exactly correct, it forgets to do argv_free() if
call_usermodehelper_fns() returns -ENOMEM. And I guess you forgot
to remove the unused "struct subprocess_info *info".

Oleg.

