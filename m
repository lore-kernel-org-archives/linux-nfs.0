Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60520 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757276Ab2CVCyD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 22:54:03 -0400
Message-ID: <4F6A93F5.1070202@panasas.com>
Date: Wed, 21 Mar 2012 19:52:37 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        Oleg Nesterov <oleg@redhat.com>
CC: "Rafael J. Wysocki" <rjw@sisk.pl>, <keyrings@linux-nfs.org>,
        <linux-security-module@vger.kernel.org>,
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
References: <4F691059.30405@panasas.com> <4F691383.5040506@panasas.com> <4F6A92FC.6060702@panasas.com>
In-Reply-To: <4F6A92FC.6060702@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/21/2012 07:48 PM, Boaz Harrosh wrote:
> On 03/20/2012 04:32 PM, Boaz Harrosh wrote:
>>
<snip>
> 
> Please review my patchset above, and comment. If you guys want I can combine
> the two sets into one patchset ASAP. (Will try to finish an RFC tomorrow)
> Since we are inventing the same mechanisms for slightly different needs.
> But basically we both need support for the waiter to be returning before
> the child has completed.
> 

I forgot to ask, what is the official git tree for these patches?

Currently I picked them up from the linux-next/master tree.
Is there a more stable source for these? (Though I can just carry them
as a patchset, I'll need to rebase them anyway)

> Thanks
> Boaz

