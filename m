From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 2/2] Fix lockd panic
Date: Sat, 12 Jan 2008 01:51:30 -0500
Message-ID: <47886372.7020709@redhat.com>
References: <4781BE72.7050404@redhat.com> <18307.2757.579354.785142@notabene.brown> <47843957.9060208@redhat.com> <478450EA.7030608@redhat.com> <478559C5.5020608@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@suse.de>, NFS list <linux-nfs@vger.kernel.org>,
	cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755840AbYALGeU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Jan 2008 01:34:20 -0500
In-Reply-To: <478559C5.5020608@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wendy Cheng wrote:

> The point here is "with this patch, f_locks it not used at all any 
> more." Note that we have a nice inline function "nlm_file_inuse", why 
> should we use f_locks (that I assume people agree that it is awkward) 
> ? Could we simply drop f_locks all together in this section of code?
>
Start to have a second thought about this ....

Removing f_locks does make the code much more readable. However, if 
inode->i_flock list is long, e.g. large amount of (clients) hosts and/or 
processes from other hosts competing for the same lock, we don't want to 
do the list walk twice within nlm_traverse_files(). Intuitively this is 
unlikely but I prefer not changing the current behavior. As the result, 
I'm withdrawing the patch all together.

The first patch will handle the issue correctly. Will submit it after 
this post.

-- Wendy

