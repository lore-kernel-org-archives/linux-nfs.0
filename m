Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:41653 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327AbaAPQhM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jan 2014 11:37:12 -0500
Received: by mail-ie0-f178.google.com with SMTP id x13so4090230ief.37
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jan 2014 08:37:12 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: nfs attribute cache question
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <E2A4F98B-D2FD-4908-96FB-11133872C00E@oracle.com>
Date: Thu, 16 Jan 2014 11:37:07 -0500
Cc: ranjith ruban <ranjithruban@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CF9B51B1-0798-49F0-B181-1C87D7F013A2@primarydata.com>
References: <CAPQuqip0WvBLNPN+7ahMrzPA=GdUroQXWH9vo_SrXPJ70mHkEg@mail.gmail.com> <E2A4F98B-D2FD-4908-96FB-11133872C00E@oracle.com>
To: Lever Charles Edward <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 16, 2014, at 10:55, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jan 16, 2014, at 6:31 AM, ranjith ruban <ranjithruban@gmail.com> wrote:
> 
>> Hello
>> 
>> I had set nfs mount actiomeo option for 300 seconds for a share. The
>> client is an openvz server with container filesystems in nfs . Server
>> is netapp.
>> 
>> While going through the tcpdump i see below
>> 
>> 125     2014-01-15 16:06:01.770522      10.X.0.X    10.X.0.X     NFS
>> 190     V3 GETATTR Call (Reply In 126), FH: 0x496fe5c5
>> 126     2014-01-15 16:06:01.770637      10.X.0.X    10.X.0.X    NFS
>> 182     V3 GETATTR Reply (Call In 125)  Regular File mode: 0644 uid:
>> 0 gid: 0
>> 
>> this call returns file id 2691421
>> 
>> find /vz/private/X/ -inum 2691421 -exec ls -l {} \;
>> -rw-r--r-- 1 root root 1128 Jul 14  2011 /vz/private/X/fs/root/etc/passwd
>> 
>> Now after a minute i do see the same call again to same file handle.
>> 
>> 294   2014-01-15 16:07:01.771152      10.X.0.X    10.X.0.X     NFS
>> 190     V3 GETATTR Call (Reply In 295), FH: 0x496fe5c5
>> 295   2014-01-15 16:07:01.771261      10.X.0.X     10.X.0.X   NFS
>> 182     V3 GETATTR Reply (Call In 294)  Regular File mode: 0644 uid: 0
>> gid: 0
>> 
>> mount options
>> # 10.X.0.X:/vol/vz2/private on /vz/private type nfs
>> (rw,noatime,nodiratime,soft,timeo=60,nfsvers=3,retrans=2,rsize=8192,wsize=8192,actimeo=300,addr=10.X.0.X)
>> 
>> why does this happens with actimeo=300 . The second call in 1 minute
>> should be answered from cache is it ?. Can some tuning be done to
>> reduce this?.
> 
> With NFSv3, open(2) on the client results in an on-the-wire GETATTR, independent of the freshness of the file’s attribute cache.  See “DATA AND METADATA COHERENCE” in the nfs(5) man page.

We should probably amend the manpage to make it clear that the ac* mount options control timeout values only, and that the NFS client may still end up sending a GETATTR if cache coherency requires it.

--
Trond Myklebust
Linux NFS client maintainer

