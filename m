Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:64282 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008Ab0HMVQY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 17:16:24 -0400
Subject: Re: NFS and file locking for use with sqllite
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <AANLkTik_gAeTWhD_=zSUrqh2eYir=q4bK4cJ6UdGQ11M@mail.gmail.com>
Date: Fri, 13 Aug 2010 17:15:40 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <0C88B758-1DE8-4CFB-9546-A30104009A12@oracle.com>
References: <AANLkTik_gAeTWhD_=zSUrqh2eYir=q4bK4cJ6UdGQ11M@mail.gmail.com>
To: Rahul Nabar <rpnabar@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 13, 2010, at 4:54 PM, Rahul Nabar wrote:

> I came across a snippet in the sqlite FAQ that warns against using
> some network file-systems due to file locking bugs. In the past I've
> had excellent experiences using NFS+Linux (CentOS) so was wondering if
> people had comments if or not this (fairly vague) warning might apply
> to NFS or not at all?
> 
> From the sqlite FAQ:
> 
> .........the file locking logic of many network filesystems
> implementation contains bugs (on both Unix and Windows). If file
> locking does not work like it should, it might be possible for two or
> more client programs to modify the same part of the same database at
> the same time, resulting in database corruption..........

It's really not clear what is meant by this vague warning.  Maybe you should ask for details from the sqlite development community.

> Does file-locking in NFS work "as it should". Is this dependent on the
> particular options I pass to the NFS mount? e.g. I usually use hard
> mounts with the intr option.
> A snippet from my fstab:
> 
> eustorage:/opt /opt nfs
> rw,nodev,noatime,nfsvers=3,timeo=110,retrans=50,hard,intr,proto=udp,rsize=32768,wsize=32768
> 0 0
> 
> If I desired the ideal file-locking properties should I be modifying /
> adding any particular option?

You have two choices on Linux clients:  "lock" and "nolock".  They control whether file locks appear to other clients or not.  I assume your applications cares about serialization with processes only on the same client where it is running.  Mount options almost certainly do not matter in this case.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



