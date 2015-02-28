Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:48767 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbbB1PVu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Feb 2015 10:21:50 -0500
Received: by mail-vc0-f173.google.com with SMTP id hy4so8351910vcb.4
        for <linux-nfs@vger.kernel.org>; Sat, 28 Feb 2015 07:21:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1830.1424969974@warthog.procyon.org.uk>
References: <1424964991.10136.8.camel@primarydata.com>
	<1411654543.3044.24.camel@leira.trondhjem.org>
	<28059.1411650278@warthog.procyon.org.uk>
	<6150.1424947519@warthog.procyon.org.uk>
	<1655.1424969471@warthog.procyon.org.uk>
	<1830.1424969974@warthog.procyon.org.uk>
Date: Sat, 28 Feb 2015 10:21:50 -0500
Message-ID: <CAHQdGtT9GZpUw5T3zjmRMtO_e34CWy9ds14hB2CAGs8h9f2Jvw@mail.gmail.com>
Subject: Re: NMI/soft lockup in nfs_delegation_need_return()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: David Howells <dhowells@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 26, 2015 at 11:59 AM, David Howells <dhowells@redhat.com> wrote:
> David Howells <dhowells@redhat.com> wrote:
>
>> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>
>> > This patch ensures that the superblock doesn't go ahead and disappear
>> > underneath us while the state manager thread is returning delegations.
>>
>> It doesn't help.  It seem likely that it would, though.  The superblock is
>
> It doesn't seem likely, that is...
>
>> unlikely to disappear since there's an active tar running against it.
>
> David

Hi David,

Could you please retest using the patches that are currently in my
'devel' git branch?

git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel

They fix up a number of minor issues with the delegation code,
specifically ones that might cause a delegation to be removed
prematurely.

Thanks!
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
