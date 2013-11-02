Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:59378 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753516Ab3KBCuS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Nov 2013 22:50:18 -0400
Message-ID: <527466DA.3060007@davequigley.com>
Date: Fri, 01 Nov 2013 22:43:38 -0400
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "cye@redhat.com" <cye@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix oops when trying to set SELinux label
References: <1383317372-3373-1-git-send-email-jlayton@redhat.com>	<20131101120211.586aef7a@corrin.poochiereds.net>	<1383324599.2911.2.camel@leira.trondhjem.org> <20131101125719.38843cfb@tlielax.poochiereds.net>
In-Reply-To: <20131101125719.38843cfb@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/1/2013 12:57 PM, Jeff Layton wrote:
> On Fri, 1 Nov 2013 16:50:00 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>
>> On Fri, 2013-11-01 at 12:02 -0400, Jeff Layton wrote:
>>> It looks like _nfs4_get_security_label() has the same problem, but I've
>>> so far been unable to get it to be called, so I didn't patch it. It
>>> seems like getxattr does some special stuff for SELinux labels that
>>> cause them only to ever be fetched once.
>>>
>>> Is there some trick to it?
>>>
>>
>> Doesn't 'ls -Z' cause them to security label to be read again?
>>
>
> As best I can tell, security labels are set on the inode when the inode
> is instantiated, and then are reset on changes (i.e. setxattr). If
> another client changes the label though, it's not clear to me how your
> client would ever notice it until the inode is dropped from the cache.
>
> ISTR Eric Paris explaining to me that they do that for performance
> reasons but it seems like something that needs to be reconsidered in
> light of labeled NFS. Not picking up a security label change seems like
> a bug, IMO...
>
>> Either way, the fix is clearly needed, so I've added the patch, and Cced
>> stable.
>>
>
> Thanks!
>

This was the point of the original requirement for a label change 
notification. Its important for us to pick up that label change when it 
gets changed from another client or on the server directly. As of when 
we implemented the prototype the cache invalidation for the security 
attribute in NFSv4 was 5 seconds and we questioned whether or not it was 
necessary to have an explicit change notification or if waiting 5 
seconds was sufficient.

Dave
