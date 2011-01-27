Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41449 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974Ab1A0AoR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jan 2011 19:44:17 -0500
In-Reply-To: <1296086349.7127.55.camel@heimdal.trondhjem.org>
References: <1295998215.6867.22.camel@heimdal.trondhjem.org>
	<21515.1296030022@jrobl>
	<1296072867.7127.26.camel@heimdal.trondhjem.org>
	<1296074585.7127.33.camel@heimdal.trondhjem.org>
	<AANLkTik2JJt4vcX8mMJmz+uwJU01vpMwF0UjQ+3QFAtp@mail.gmail.com>
	<1296086349.7127.55.camel@heimdal.trondhjem.org>
Date: Thu, 27 Jan 2011 11:44:15 +1100
Message-ID: <AANLkTim1-dwNjTpyCi5qBjCer5vgPo4qSNfK7Htd_vfL@mail.gmail.com>
Subject: Re: 2.6.38-rc2... NFS sillyrename is broken...
From: Nick Piggin <npiggin@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. R. Okajima" <hooanon05@yahoo.co.jp>, linux-nfs@vger.kernel.org,
        Linux Filesystem Development <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jan 27, 2011 at 10:59 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2011-01-27 at 10:50 +1100, Nick Piggin wrote:
>> On Thu, Jan 27, 2011 at 7:43 AM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > On Wed, 2011-01-26 at 15:14 -0500, Trond Myklebust wrote:
>> >> The alternative would be to add a callback that can be called after
>> >> dentry_iput() if DCACHE_NFSFS_RENAMED is true, and that takes the parent
>> >> and (negative) dentry as the arguments.
>> >> sillyrename doesn't need the inode as an argument, but it definitely
>> >> needs the parent dentry so that it can check for races with
>> >> ->lookup()...
>> >
>> > The following (compile tested only!) patch illustrates what I mean.
>>
>> We could do this. CEPH also want a way to get d_parent in the inode
>> unlink path.
>>
>> I think I can actually check for dentry->d_count == 0 rather than
>> dentry->d_parent == NULL here, and avoid clearing d_parent
>> entirely. That might be the better solution for 2.6.38, because other
>> code I've missed might be expecting to use d_parent.
>
> I'm not sure I understand. By the time we hit d_kill() we know that
> dentry->d_count == 0.

The dcache patch to set d_parent to NULL was done so that when
walking the other way up the path we can check that the parent is
still valid.

But we could just check for d_count != 0 which means the parent has
to be valid as well (we have rename protection as well).
