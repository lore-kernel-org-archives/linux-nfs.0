Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:59385 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753759Ab3KBCwv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Nov 2013 22:52:51 -0400
Message-ID: <52746772.4050803@davequigley.com>
Date: Fri, 01 Nov 2013 22:46:10 -0400
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>
CC: "cye@redhat.com" <cye@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix oops when trying to set SELinux label
References: <1383317372-3373-1-git-send-email-jlayton@redhat.com> <20131101120211.586aef7a@corrin.poochiereds.net> <1383324599.2911.2.camel@leira.trondhjem.org> <20131101125719.38843cfb@tlielax.poochiereds.net> <A1A30425-FA21-4D8B-ABB4-F7E02C2D5DEA@netapp.com>
In-Reply-To: <A1A30425-FA21-4D8B-ABB4-F7E02C2D5DEA@netapp.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/1/2013 1:05 PM, Myklebust, Trond wrote:
>
> On Nov 1, 2013, at 12:57, Jeff Layton <jlayton@redhat.com> wrote:
>
>> On Fri, 1 Nov 2013 16:50:00 +0000
>> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>
>>> On Fri, 2013-11-01 at 12:02 -0400, Jeff Layton wrote:
>>>> It looks like _nfs4_get_security_label() has the same problem, but I've
>>>> so far been unable to get it to be called, so I didn't patch it. It
>>>> seems like getxattr does some special stuff for SELinux labels that
>>>> cause them only to ever be fetched once.
>>>>
>>>> Is there some trick to it?
>>>>
>>>
>>> Doesn't 'ls -Z' cause them to security label to be read again?
>>>
>>
>> As best I can tell, security labels are set on the inode when the inode
>> is instantiated, and then are reset on changes (i.e. setxattr). If
>
> …and on getxattr, afaics.
>
>> another client changes the label though, it's not clear to me how your
>> client would ever notice it until the inode is dropped from the cache.
>>
>> ISTR Eric Paris explaining to me that they do that for performance
>> reasons but it seems like something that needs to be reconsidered in
>> light of labeled NFS. Not picking up a security label change seems like
>> a bug, IMO...
>
> To be effective, the security label should normally be set at file creation time. It should rarely, if ever, change. Why would you need to change it from a different client?
>
> Cheers,
>    Trond
>

That isn't completely true. Security labels should be set on creation 
but they may change. An SELinux label consists of 
user:role:type:level/categories. In RHEL and Fedora level/categories 
implements something called multi category security. One level multiple 
categories with the constraint on categories being that all must match 
for access to be allowed. This is how sVirt work. It picks two 
categories and setups the qemu process to start with these categories 
and then manipulates the files  on disk to have these categories such 
that even though the qemu_t proess can access the files type enforcement 
wise the categories deny it. Its what allows for SELinux based per 
process separation of a type.

Dave
