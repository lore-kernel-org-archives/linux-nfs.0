Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31443 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287Ab2BGPol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 10:44:41 -0500
Message-ID: <4F3146E0.4040704@netapp.com>
Date: Tue, 07 Feb 2012 10:44:32 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xemul@parallels.com" <xemul@parallels.com>,
        "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jbottomley@parallels.com" <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 1/4] NFS: make nfs_client_list per net ns
References: <20120123172605.29637.15682.stgit@localhost6.localdomain6>  <4F3143F4.3010502@netapp.com> <1328628888.4124.16.camel@lade.trondhjem.org>
In-Reply-To: <1328628888.4124.16.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/07/12 10:34, Myklebust, Trond wrote:

> On Tue, 2012-02-07 at 10:32 -0500, Bryan Schumaker wrote:
>> I fixed up my bisect and identified this patch instead.  The problem I'm seeing is:
>>
>>   CC [M]  fs/nfs/delegation.o
>>   CC [M]  fs/nfs/idmap.o
>> fs/nfs/idmap.c: In function 'rpc_pipefs_event':
>> fs/nfs/idmap.c:535:9: error: implicit declaration of function 'net_generic' [-Werror=implicit-function-declaration]
>> fs/nfs/idmap.c:535:50: error: 'nfs_net_id' undeclared (first use in this function)
>> fs/nfs/idmap.c:535:50: note: each undeclared identifier is reported only once for each function it appears in
>> fs/nfs/idmap.c:540:82: error: dereferencing pointer to incomplete type
>> fs/nfs/idmap.c:540:224: error: dereferencing pointer to incomplete type
>> cc1: some warnings being treated as errors
>>
>> make[2]: *** [fs/nfs/idmap.o] Error 1
>> make[1]: *** [fs/nfs] Error 2
>> make: *** [fs] Error 2
>>
>> I think you need to add: #include "netns.h" to idmap.c.
>>
>> - Bryan
> 
> That should already be there in the 'devel' branch. See commit
> 17347d03c008e2f504c33bb4905cdad0abc01319.
> 


Yes, but once I fixed this I was able to find the initial problem I was searching for (I have no idea how git led me to the wrong patch on my first attempt).

- Bryan

