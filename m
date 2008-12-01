From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] Support for IPv6 in the showmount command
Date: Mon, 01 Dec 2008 14:30:22 -0500
Message-ID: <49343B4E.9030203@RedHat.com>
References: <20081118192711.22516.2801.stgit@ingres.1015granger.net> <492C0B6C.7070104@RedHat.com> <53AEB619-3E79-4E18-AF25-B5AFE821FCBE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44558 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550AbYLATef (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Dec 2008 14:34:35 -0500
In-Reply-To: <53AEB619-3E79-4E18-AF25-B5AFE821FCBE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Nov 25, 2008, at Nov 25, 2008, 9:27 AM, Steve Dickson wrote:
>> Chuck Lever wrote:
>>> Hi Steve-
>>>
>>> These patches implement support for rpcbind v3/v4 queries and IPv6 NFS
>>> servers in the showmount command.  Please consider these for the next
>>> release of nfs-utils.
>>>
>>> Thanks!
>>>
>>> ---
>>>
>>> Chuck Lever (4):
>>>      showmount command: support querying IPv6 servers
>>>      showmount command: move logic to acquire RPC client handle out
>>> of main()
>>>      showmount command: Remove unused local getport() implementation
>>>      showmount command: call nfs_getport instead of local getport
>>>
>>>
>>> utils/showmount/showmount.c |  237
>>> +++++++++++++++++--------------------------
>>> 1 files changed, 91 insertions(+), 146 deletions(-)
>> All four patch have been committed and regression tested...
> 
> Thanks.
> 
> Neil posted a patch around start_statd earlier this week.  My next set
> of patches touches this part of mount.nfs. Are you planning to apply his
> patch?  I can wait for that and rework my patches when you're ready.
I believe everything that's needed should be there... let me know if something
is missing... 

steved.

