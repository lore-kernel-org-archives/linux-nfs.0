From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 2/2] Fix lockd panic
Date: Tue, 08 Jan 2008 23:43:22 -0500
Message-ID: <478450EA.7030608@redhat.com>
References: <4781BE72.7050404@redhat.com> <18307.2757.579354.785142@notabene.brown> <47843957.9060208@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@suse.de>, NFS list <linux-nfs@vger.kernel.org>,
	cluster-devel@redhat.com
To: wcheng@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753265AbYAIE0Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 23:26:16 -0500
In-Reply-To: <47843957.9060208@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wendy Cheng wrote:

> Neil Brown wrote:
>
>> Some options:
>>
>> Have an initial patch which removes all references to f_locks and
>> includes the change in this patch. With that in place your main
>> patch won't introduce a bug. If you do this, you should attempt to
>> understand and justify the performance impact (does nlm_traverse_files
>> become quadratic in number of locks. Is that acceptable?).
>>
>> Change the first patch to explicitly update f_count if you bypass the
>> call to nlm_inspect_file.
>>
>> something else???
>>
>>
>
> Let's see what hch says in another email... will come back to this soon.
>

Will do a quick and dirty performance measure tomorrow when I get to the 
office. Then we'll go from there.

-- Wendy
