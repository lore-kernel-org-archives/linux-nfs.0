From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] nfs lockd: detect grace_list corruption
Date: Wed, 06 May 2009 17:17:20 +0800
Message-ID: <4A0155A0.4020008@cn.fujitsu.com>
References: <49F12D78.2040304@cn.fujitsu.com> <20090424231252.GD22477@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: neilb@suse.de, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org,
	FNST-Bian Naimeng <biannm@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49153 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753111AbZEFJR6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2009 05:17:58 -0400
In-Reply-To: <20090424231252.GD22477@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields said the following on 2009-4-25 7:12:
> On Fri, Apr 24, 2009 at 11:09:44AM +0800, Wang Chen wrote:
>> Although I can't reproduce it now, it really happened that some lock manager
>> started grace period but didn't end it.
>> This causes an lm entry be left in grace_list, and when service nfs restart,
>> the same lm will be added again into the list.
>> As you know, adding an entry, which is in the list, to a list will leads to
>> list corruption.
> 
> I'd really like to understand why locks_end_grace() isn't being called.
> I'm probably overlooking something obvious, but I just can't see how
> lockd or nfsd can be shut down right now without locks_end_grace() being
> called.
> 

Me neither can figure out why locks_end_grace() isn't being called.

But do locks_start_grace() twice can trigger this warning too.
You can do
1. service nfs restart
2. (immediately) kill -s SIGKILL lockd
this can trigger
---
lockd(void *vrqstp)
...
		if (signalled()) {
			flush_signals(current);
			if (nlmsvc_ops) {
				nlmsvc_invalidate_all();
				set_grace_period();
---
and makes locks_start_grace() be called twice without locks_end_grace().

So I still suggest to do something to protect the lm list. :)

