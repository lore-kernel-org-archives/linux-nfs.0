Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45454 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173AbaGJRvh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 13:51:37 -0400
Date: Thu, 10 Jul 2014 13:51:36 -0400
To: Andreas Fenkart <afenkart@gmail.com>
Cc: rond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, Daniel Mack <zonque@gmail.com>
Subject: Re: `ls` shows no files in mounted nfs folder, but ls 'file' works
Message-ID: <20140710175136.GA26561@fieldses.org>
References: <CALtMJECmW-yYgD3W5FUxQZJVZkb5NSJpQ5V9Q3ZE=1NKeCDtOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALtMJECmW-yYgD3W5FUxQZJVZkb5NSJpQ5V9Q3ZE=1NKeCDtOA@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 12:07:22PM +0200, Andreas Fenkart wrote:
> Found regression introduced by this patch
> 
> 311324ad NFS: Be more aggressive in using readdirplus for 'ls -l' situations"
> 
> # cd /bin
> -sh: cd: /bin: Not a directory
> root@192:/# pwd
> /
> root@192:/# ls /bin
> ls: /bin
> root@192:/# ls -l /bin/sh
> lrwxrwxrwx    1 root     root             9 Jun 16 13:59 /bin/sh -> /bin/bash
> 
> the mount options of the client, an embedded system, mounting nfsroot:
> nfs(rw,relatime,vers=2,rsize=4096,wsize=4096,namlen=255,hard,nolock,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.xx.xx,mountvers=1,mountproto=udp,local_lock=all,addr=192.168.xx.xx)
> vers: 3.16.0-rc1
> 
> the server exports:
> /exports/rootfs 192.168.xx.xx(rw,no_root_squash,subtree_check)
> vers: 3.14-1-amd64 #1 SMP Debian 3.14.4-1 (2014-05-13) x86_64 GNU/Linux
> 
> reverting above patch, dirlisting with 'ls /' works again

Is this still happening?

--b.
