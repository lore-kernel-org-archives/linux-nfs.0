Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:61179 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbaBGTr1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Feb 2014 14:47:27 -0500
Received: by mail-ig0-f173.google.com with SMTP id c10so2489436igq.0
        for <linux-nfs@vger.kernel.org>; Fri, 07 Feb 2014 11:47:26 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: readdir vs. getattr
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140207153028.7df0d209@notabene.brown>
Date: Fri, 7 Feb 2014 14:47:23 -0500
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Message-Id: <6F6E3499-4C95-44B4-BBD0-CFFBFC4F48DA@primarydata.com>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com> <20130404151507.GA8484@umich.edu> <CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com> <1365090480.10726.22.camel@leira.trondhjem.org> <20140129182532.7479eeda@notabene.brown> <1342984553.746756.1390987303295.JavaMail.zimbra@desy.de> <20140129071841.1979a48c@tlielax.poochiereds.net> <20140206134539.53d09434@notabene.brown> <20140206135101.1cc83442@notabene.brown> <1391724779.6399.2.camel@leira.trondhjem.org> <20140207153028.7df0d209@notabene.brown>
To: Brown Neil <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 6, 2014, at 23:30, NeilBrown <neilb@suse.de> wrote:

> On Thu, 06 Feb 2014 17:12:59 -0500 Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> 
>> On Thu, 2014-02-06 at 13:51 +1100, NeilBrown wrote:
>>> On Thu, 6 Feb 2014 13:45:39 +1100 NeilBrown <neilb@suse.de> wrote:
>>> 
>>> 
>>>> The change to nfs_update_inode fixes an issue that had me stumped for a
>>>> while.  It was still sending lots of GETATTR requests even after it had
>>>> switched to READDIRPLUS instead of using cached info.  So that might be a
>>>> genuine bug that should be fixed independently of this patch.
>>> 
>>> I managed to post the wrong version of the patch, which didn't have this
>>> change.  Sorry.
>>> 
>>> Here is the real one.
>>> 
>>> NeilBrown
>> 
>> Hi Neil,
>> 
>> Is there any reason why this patch couldn't just be replaced with the
>> following?
> 
> Well.... the following doesn't make any change in my test case. :-(
> 
> In my test case there is a large directory on the server which doesn't change.
> The client sends lots of requests to see if it has changed, but it hasn't.
> (Tested with the labeled-NFS-regression fix applied)
> 
> Your patch only changes behaviour if nfs_force_lookup_revalidate is called,
> and that is only called when NFS_ATTR_FATTR_CHANGE is set, or when an NFSv4
> client modifies the directory.  Neither of those are happening.

Right, but I really do not know how to fix that case.

I read your patch as saying: "If we're revalidating a dentry and we find that the directory has not changed but that the dentry’s inode needs revalidation, then invalidate that directory's attribute, acl and readdir cached data. Then drop the dentry”. I have a hard time seeing how that can be beneficial.

If we were to modify it, to only invalidate the readdir cached data, then that might improve matters, but it is still hard for me to see how a single inode needing revalidation can justify a full re-read of the parent directory in the general case. You may end up rereading thousands of readdir entries from the server just because someone did a path lookup.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

