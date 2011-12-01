Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.onthe.net.au ([203.22.196.249]:57048 "EHLO
	smtp1.onthe.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab1LAHXL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 02:23:11 -0500
Date: Thu, 1 Dec 2011 18:23:08 +1100
From: Chris Dunlop <chris@onthe.net.au>
To: Tyler Hicks <tyhicks@canonical.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        David Howells <dhowells@redhat.com>, Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Dave Kleikamp <shaggy@kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Greg Kroah-Hartman <gregkh@suse.de>, Al Viro <viro@zeniv.linux.org.uk>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@TELEMANN.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org,
        ecryptfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Message-ID: <20111201072308.GA10932@onthe.net.au>
References: <1321861008-20611-1-git-send-email-chris@onthe.net.au>
 <20111129082501.GA569@onthe.net.au>
 <20111201065024.GB495@boyd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111201065024.GB495@boyd>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 12:50:25AM -0600, Tyler Hicks wrote:
> On 2011-11-29 19:25:01, Chris Dunlop wrote:
>> I haven't seen any response to this patch which fixes an Oops in
>> d_revalidate. I hit this using NFS, but various other file
>> systems look to be likewise vulnerable, hence the broadness of
>> the patch. The sequence leading to the Oops is:
>> 
>> lookup_one_len() [fs/namei.c]
>>    calls __lookup_hash() [fs/namei.c] with nd == NULL,
>>       which can then call the file system specific d_revalidate(), passing in nd == NULL
>>          which will then Oops if nd is used without checking
> 
> Hey Chris - Can you share what you were trying to do when you hit this?
> Were you stacking eCryptfs on top of NFS? Another stacked filesystem on
> top of NFS?
>
> Do you *need* a stacked filesystem to work on top of NFS? If so, we'll
> need to discuss a way forward. Al has previously shown a dislike of
> eCryptfs passing around nameidata (for good reason), but that is what
> NFS currently requires. I looked at doing this a few months back, but
> never got to the implementation stage.

Actually, no, it wasn't eCryptfs or another stacked filesystem.
It seems my dirty little secret must come out: I hit the problem
when trying to use the (necessarily) out-of-tree zfsonlinux
(ZoL) [1], on an NFS root machine.

I don't know exactly what ZoL is using lookup_one_len() for, nor
how to fix it so it isn't, but I've given them the heads up that
it's not supposed to be used outside of original file system [2].

Chris.

[1] http://zfsonlinux.org/
[2] https://github.com/zfsonlinux/zfs/issues/456
