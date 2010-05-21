Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57378 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934480Ab0EURIG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 May 2010 13:08:06 -0400
Date: Fri, 21 May 2010 13:08:04 -0400
To: Christopher Hawkins <chawkins@bplinux.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4 hang
Message-ID: <20100521170804.GA9639@fieldses.org>
References: <3726796.301274385081605.JavaMail.javamailuser@localhost> <25273515.321274385268620.JavaMail.javamailuser@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <25273515.321274385268620.JavaMail.javamailuser@localhost>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, May 20, 2010 at 03:54:28PM -0400, Christopher Hawkins wrote:
> Hello, 
> 
> I have a bash script that sets up a root filesystem over NFS. The method works fine over NFS3 but hangs when using NFS4 as a transport. Hoping someone can help me figure out why?
> 
> In a nutshell:
> 
> 1. The node boots into a ramdisk that has a few thousand files in it already
> 2. connects to an NFS server exporting / and mounts that in a tmp dir
> 3. bash (on the booting node) loops through the local and remote filesystem and creates a local symlink to anything in the nfs root that it doesn't already have.

Wild.

> Export options are: / 192.168.1.0/24(rw,no_root_squash,no_subtree_check,fsid=0)
> Mount options are: rw,sync,noatime,rsize=1024,wsize=1024
> 
> rpcidmapd, portmap, statd are running on server and client, and rpc_pipefs is mounted on both as well. The script currently makes about 6200 links, total. Nfs4 hangs about 90% of the way through. I removed the directory it was hanging on (a simple, empty dir) and then it just hung on the next one.

Is it possible there's some idmap deadlock?  (If say an upcall to idmapd
is hanging because the mapping requires access to some file that isn't
there yet?)

A sysrq-T trace might help.

--b.

> Really appreciate any help or pointers on where to look for more info. Thanks!
> 
> Chris
> 
> 
>    
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
