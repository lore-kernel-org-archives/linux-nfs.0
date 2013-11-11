Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:48837 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab3KKVMz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 16:12:55 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: NFS atime behavior is not documented
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1384203736.7614.15.camel@leira.trondhjem.org>
Date: Mon, 11 Nov 2013 16:12:50 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <803EA92F-97E6-4856-9860-04E1B1984868@oracle.com>
References: <E4BE40FF-9F81-4688-BD39-1E583DDCEA4A@oracle.com> <6EE5262F-5B2E-4F10-A600-A60F30C0A23E@netapp.com> <2EFADFB9-6520-4ED3-A7A0-B87451885DFB@oracle.com> <1384203736.7614.15.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 11, 2013, at 4:02 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-11-11 at 15:35 -0500, Chuck Lever wrote:
>> On Nov 11, 2013, at 12:33 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>> 
>>> 
>>> On Nov 11, 2013, at 11:50, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> 
>>>> Hi-
>>>> 
>>>> It was recently pointed out to me that the behavior of atime on NFS mount points is pretty dodgy, yet this is not documented anywhere, not even in the venerable and unmaintained Linux NFS FAQ.
>>>> 
>>>> A good place to cover this topic might be nfs(5).  It could discuss how the Linux NFS client deals with the various *atime mount options (mostly be collapsing them into relatime, all the time).  And it could discuss how file timestamps are updated when the physical backing store is on another system.
>>>> 
>>>> Thoughts?  Comments?
>>> 
>>> NFS atime is not the same as relatime.
>>> 
>>> Our atime is only updated when a READ rpc call goes to the server. Cached reads do not, for instance, trigger an atime update. That is a very different model than the relatime model.
>> 
>> Yes, but /proc/mounts shows the "relatime" option on NFS mounts.  And apparently it doesn't go away if you specify "noatime," for example.
>> 
>> Basically it looks to some people like NFS ignores all the atime mount options.  We should document how NFS behaves, or fix it.
> 
> We _should_ ignore all atime mount options.

Makes sense.

> I'm fine with documenting the behaviour somewhere, but my point was that
> documenting it in terms of "relatime" is not correct. We could, however,
> clear that default MNT_RELATIME flag that 'do_mount' conveniently sets
> for us.

I'm operating from what users can observe, and they see "relatime" in /proc/mounts, which is why I described it that way.  /proc/mounts is clearly wrong, then.

Can you make the kernel work the way you prefer?  I'm happy to provide an update to nfs(5) that documents that preference.  I think we do need to discuss how timestamps work on NFS, and exactly what happens when "*atime" mount options are specified.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




