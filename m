Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:38674 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023Ab2KLIiH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 03:38:07 -0500
Message-ID: <50A0B562.2090807@parallels.com>
Date: Mon, 12 Nov 2012 12:37:54 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
CC: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before connecting
 local transports
References: <20121008105437.18668.99905.stgit@localhost.localdomain> <20121009193506.GA19680@fieldses.org> <5098E31A.5080801@parallels.com> <20121106120642.GA6718@fieldses.org> <20121106124035.GA20522@infradead.org> <20121106130705.GC6718@fieldses.org> <20121106131018.GA12211@infradead.org> <20121106133605.GD6718@fieldses.org> <20121107183355.GA7421@fieldses.org>
In-Reply-To: <20121107183355.GA7421@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

07.11.2012 22:33, J. Bruce Fields пишет:
> On Tue, Nov 06, 2012 at 08:36:05AM -0500, J. Bruce Fields wrote:
>> On Tue, Nov 06, 2012 at 08:10:18AM -0500, Christoph Hellwig wrote:
>>> On Tue, Nov 06, 2012 at 08:07:06AM -0500, J. Bruce Fields wrote:
>>>> So you're worried that a bug in the nfs code could modify the root and
>>>> then not restore it?
>>>
>>> At least the link you pointed to earlier never sets it back.
>>
>> This? http://thread.gmane.org/gmane.linux.kernel/1259986/focus=47687
>>
>> 	+	get_fs_root(current->fs, &root);
>> 	+	set_fs_root(current->fs, &transport->root);
>> 	+
>> 	 	status = xs_local_finish_connecting(xprt, sock);
>> 	+
>> 	+	set_fs_root(current->fs, &root);
>> 	+	path_put(&root);
>>
>>> Instead
>>> of messing with it I'd rather have the sunrpc code use vfs_path_lookup
>>> and not care about current->fs->root at all.
>>
>> The annoyance is that the lookup happens somewhere lower down in the
>> networking code (net/unix/af_unix.c:unix_find_other, I think).  So we'd
>> need some new (internal) API.  We'd likely be the only user of that new
>> API.
>
> So, if the only drawback is really just the risk of introducing a bug
> that leaves the fs_root changed--the above seems simple enough for that
> not to be a great risk, right?
>

If we unshare rpciod fs struct (which is exported already), then we won't affect 
other kthreads by root swapping.
But would be great to hear Trond's opinion about this approach.

Trond, could you tell us your feeling about all this?

> Is there any other hazard to doing this that people can think of?
>
> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
