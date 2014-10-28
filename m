Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:49371 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbaJ1OQi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 10:16:38 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: NFSv4 idmap misbehavior
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <alpine.DEB.2.02.1410281006010.27485@main.carlh.net>
Date: Tue, 28 Oct 2014 10:16:02 -0400
Cc: David Howells <dhowells@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F9A7C5A6-542A-4573-BD66-844B8BD3F57F@oracle.com>
References: <70DD1EAE-3001-46E7-92D6-AEB928E8FBA1@oracle.com> <alpine.DEB.2.02.1410281006010.27485@main.carlh.net>
To: Carl Hetherington <cth@carlh.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Carl-

On Oct 28, 2014, at 6:12 AM, Carl Hetherington <cth@carlh.net> wrote:

> Hi Chuck,
> 
> [snip]
> 
>> After the test has been running for ten minutes, the id_resolv
>> keys expire, and id_legacy keys appear. Before the above commit,
>> the id_resolv keys would simply be refreshed and operation
>> would continue normally.
> 
> This sounds a lot like a bug I have seen, our investigations into which
> are summarised here:
> 
> https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/1124250

Looks like a lot of folks are having trouble, and there are two or
three sets of independent symptoms reported in the comments. Thanks
for bringing it to this forum.

I might have a different issue from the bug report, though:

 + 1124250 might be a server-side problem, and my problem is
   definitely on the NFS client

 + My system works fine with kernels up to 3.12

 + I can reproduce with just one user, so probably not a key
   quota issue

 + I’ve got keyutils installed already

> There's an inexpertly written (by me) patch in that bug report (which I
> posted to this list recently, too) which (in a nutshell) makes the
> idmapper code call up to userspace to get a new key when the current ones
> have expired.

David should have a look at this.

However, your patch changes the behavior of renewing legacy ID
resolver keys AFAICT? On my system, at least, we shouldn’t even
be getting this far.

I’ll poke around more.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



