Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50006 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751421Ab2FRWOj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jun 2012 18:14:39 -0400
Date: Mon, 18 Jun 2012 18:14:37 -0400
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 and Kerberos problem in svcgssd
Message-ID: <20120618221437.GA13534@fieldses.org>
References: <20120615223028.GS20917@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20120615223028.GS20917@ics.muni.cz>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 16, 2012 at 12:30:28AM +0200, Lukas Hejtmanek wrote:
> Hello,
> 
> it seems that -n option for rpc.svcgssd produces file descriptor leaks. It
> looks like this:
> 
> ls -l /proc/25920/fd/
> total 0
> lrwx------ 1 root root 64 Jun 16 00:13 0 -> /dev/pts/0
> lrwx------ 1 root root 64 Jun 16 00:13 1 -> /dev/pts/0
> lrwx------ 1 root root 64 Jun 16 00:13 10 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 11 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 12 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 13 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 14 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 15 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 16 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 17 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 18 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 19 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 2 -> /dev/pts/0
> lrwx------ 1 root root 64 Jun 16 00:13 20 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 21 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 22 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 23 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 24 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 25 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 26 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 27 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 28 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 16 00:13 29 -> /var/tmp/nfs_0
> lr-x------ 1 root root 64 Jun 16 00:13 3 -> pipe:[24457591]
> lrwx------ 1 root root 64 Jun 16 00:13 30 -> /var/tmp/nfs_0
> l-wx------ 1 root root 64 Jun 16 00:13 4 -> pipe:[24457591]
> lr-x------ 1 root root 64 Jun 16 00:13 5 -> pipe:[24457592]
> l-wx------ 1 root root 64 Jun 16 00:13 6 -> pipe:[24457592]
> lr-x------ 1 root root 64 Jun 16 00:13 7 -> /etc/gssapi_mech.conf
> lr-x------ 1 root root 64 Jun 16 00:13 8 ->
> /proc/25920/net/rpc/auth.rpcsec.init/channel
> lrwx------ 1 root root 64 Jun 16 00:13 9 -> /var/tmp/nfs_0
> 
> Is there any known fix for this? It runs quickly from max open files..

It doesn't look familiar to me.--b.

> 
> There is some gabage collecting that results in this:
> s -l
> total 0
> lrwx------ 1 root root 64 Jun 15 23:45 0 -> /dev/pts/0
> lrwx------ 1 root root 64 Jun 15 23:45 1 -> /dev/pts/0
> lrwx------ 1 root root 64 Jun 15 23:46 10 -> /var/tmp/nfs_0 (deleted)
> lrwx------ 1 root root 64 Jun 15 23:47 11 -> /var/tmp/nfs_0 (deleted)
> lrwx------ 1 root root 64 Jun 15 23:47 12 -> /var/tmp/nfs_0
> lrwx------ 1 root root 64 Jun 15 23:45 2 -> /dev/pts/0
> lr-x------ 1 root root 64 Jun 15 23:45 3 -> pipe:[24450369]
> l-wx------ 1 root root 64 Jun 15 23:45 4 -> pipe:[24450369]
> lr-x------ 1 root root 64 Jun 15 23:45 5 -> pipe:[24450370]
> l-wx------ 1 root root 64 Jun 15 23:45 6 -> pipe:[24450370]
> lr-x------ 1 root root 64 Jun 15 23:45 7 -> /etc/gssapi_mech.conf
> lr-x------ 1 root root 64 Jun 15 23:45 8 ->
> /proc/24184/net/rpc/auth.rpcsec.init/channel
> lrwx------ 1 root root 64 Jun 15 23:45 9 -> /var/tmp/nfs_0 (deleted)
> 
> 
> -- 
> Lukáš Hejtmánek
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
