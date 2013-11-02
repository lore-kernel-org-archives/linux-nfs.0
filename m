Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:59361 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753817Ab3KBCsT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Nov 2013 22:48:19 -0400
Message-ID: <52746661.60508@davequigley.com>
Date: Fri, 01 Nov 2013 22:41:37 -0400
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
CC: "cye@redhat.com" <cye@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix oops when trying to set SELinux label
References: <1383317372-3373-1-git-send-email-jlayton@redhat.com>	 <20131101120211.586aef7a@corrin.poochiereds.net> <1383324599.2911.2.camel@leira.trondhjem.org>
In-Reply-To: <1383324599.2911.2.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/1/2013 12:50 PM, Myklebust, Trond wrote:
> On Fri, 2013-11-01 at 12:02 -0400, Jeff Layton wrote:
>> It looks like _nfs4_get_security_label() has the same problem, but I've
>> so far been unable to get it to be called, so I didn't patch it. It
>> seems like getxattr does some special stuff for SELinux labels that
>> cause them only to ever be fetched once.
>>
>> Is there some trick to it?
>>
> 
> Doesn't 'ls -Z' cause them to security label to be read again?
> 
> Either way, the fix is clearly needed, so I've added the patch, and Cced
> stable.
> 
> Cheers
>    Trond
> 

ls -Z will only cause the label to be reread if its no longer valid in
the NFSv4 cache. Otherwise it will use the in-core inode value and
return that.
