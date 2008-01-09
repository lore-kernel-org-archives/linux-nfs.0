From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: atimes not updated over NFS
Date: Wed, 09 Jan 2008 10:27:16 -0500
Message-ID: <1199892437.11141.2.camel@heimdal.trondhjem.org>
References: <20080109101313.GG9212@aym.net2.nerim.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:39613 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752184AbYAIP1V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 10:27:21 -0500
In-Reply-To: <20080109101313.GG9212-956IwFboN44acnK+F/IuxqxOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-01-09 at 11:13 +0100, Andre Majorel wrote:
> After upgrading an NFS server from kernel 2.6.12 to 2.6.23, the
> atime of files is not updated any more when clients read them :
> 
>   client$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
>   -rw-r--r-- 1 xxx xxx 0 2007-12-21_14:58:11 /nfsmnt/zz
>   client$ md5sum /nfsmnt/zz
>   d41d8cd98f00b204e9800998ecf8427e  /nfsmnt/zz
>   client$ date +%Y-%m-%d_%H:%M:%S
>   2007-12-21_15:00:28
>   client$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
>   -rw-r--r-- 1 xxx xxx 0 2007-12-21_14:58:11 /nfsmnt/zz
> 
> Reading the file locally, i.e. on the NFS server, does update the
> atime :
> 
>   server$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
>   -rw-r--r-- 1 xxx xxx 0 2007-12-21_14:58:11 /nfsmnt/zz
>   serveur$ md5sum /nfsmnt/zz
>   d41d8cd98f00b204e9800998ecf8427e  /nfsmnt/zz
>   serveur$ date +%Y-%m-%d_%H:%M:%S
>   2007-12-21_15:04:00
>   serveur$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
>   -rw-r--r-- 1 xxx xxx 0 2007-12-21_15:03:57 /nfsmnt/zz
> 
> /nfsmnt is mounted with options :
> - server : rw,noexec,nosuid,nodev,nodiratime
> - client : rw,user=root,nosuid,nodev,nodiratime,intr,rsize=8192,wsize=8192
> 
> Any ideas ?

The file is probably entirely in cache on the client. When this happens,
no READ rpc calls need to be made to the server and so the atime will
not change either.

This has always been the case, BTW...

Trond

