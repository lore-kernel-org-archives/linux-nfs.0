Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:65291 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbZIBSiW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 14:38:22 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <5ACA39DC-AACB-495F-B9C6-11CF2EB2D764@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Jason Legate <linux-nfs@proxime.net>
In-Reply-To: <20090902180841.GF946@proxime.net>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: NFS for millions of files
Date: Wed, 2 Sep 2009 14:38:13 -0400
References: <20090902180841.GF946@proxime.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sep 2, 2009, at 2:08 PM, Jason Legate wrote:
> Hi, I'm trying to setup a server that we can create millions of  
> files on over
> NFS.  When I run our creation benchmark locally  I can get around  
> 3000 files/
> second in the configuration we're using now, but only around 300/ 
> second over
> NFS.  It's mounted as this:
>
> rw 
> ,nosuid 
> ,nodev,noatime,nodiratime,hard,bg,nointr,rsize=32768,wsize=32768,tcp,
> nfsvers=3,timeo=600,actimeo=600,nocto
>
> When I mount the same FS over localhost instead of across the lan,  
> it performs
> about full speed (the 3000/sec).  Anyone have any ideas what I might  
> tweak or
> look at?
>
> We're going to be testing various XFS/LVM configs to get the best  
> performance,
> but right out the gate, NFS having a 10:1 penalty of performance  
> doesn't bode
> well.

If you are using a slow LAN (like 100Mb/s) that might be a problem.

Metadata operations (like file creation) are always slower on NFS than  
on local file systems.  There is significantly more serialization  
involved for NFS since access to the file system is shared across  
multiple systems.

You might consider a cluster file system instead of NFS if you are  
driving metadata-intensive workloads while sharing amongst only local  
clients.  Or, if you can install a fast log device for your server  
file system, that might mitigate the disk waits during each file  
creation.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



