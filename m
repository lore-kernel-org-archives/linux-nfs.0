Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:64149 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756494Ab0KST5E convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Nov 2010 14:57:04 -0500
Subject: Re: O_DIRECT, O_SYNC, or fsync() on NFS mounts?
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1290194699.3135.49.camel@heimdal.trondhjem.org>
Date: Fri, 19 Nov 2010 14:55:00 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>
Message-Id: <22FD6CA9-ACF6-4054-B369-E6F74711E290@oracle.com>
References: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com> <1290194699.3135.49.camel@heimdal.trondhjem.org>
To: Moazam Raja <moazam@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 19, 2010, at 2:24 PM, Trond Myklebust wrote:

> On Thu, 2010-11-18 at 15:34 -0800, Moazam Raja wrote:
>> Hi all,
>> 
>> I'm currently exporting a ZFS filesystem on Solaris 11 Express as NFS.
>> I have a Linux client mounting that NFS v3 filesystem with the
>> proto=tcp option.
>> 
>> My question is, what's the safest and most reliable way to write data
>> to this NFS mount on a Linux client? Should my application code use
>> O_DIRECT, or O_SYNC? Or should I be doing a write() and a fsync()? I
>> want to make sure that data is not lost and is truly committed, while
>> keeping decent performance (of course).
> 
> Any one of the above methods will ensure that the data is synced to
> disk. In addition, NFS also guarantees that your data is fully synced to
> disk when taking/freeing POSIX locks, and when you close() the file.
> 
> The choice of one method over the other depends on your application
> requirements. Not on your choice of underlying storage.

We should add that the synchronous methods (O_DIRECT and O_SYNC) guarantee that the write will go immediately to the server and return an immediate error code (like ENOSPC).  That might be an improvement over an async write, where an error report could be delayed until close(2).

But as was said above, it depends on your application's requirements.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




