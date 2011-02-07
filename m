Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48938 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233Ab1BGUME (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Feb 2011 15:12:04 -0500
Date: Mon, 7 Feb 2011 15:12:02 -0500
To: Tom Haynes <tdh@excfb.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Debugging mount failure with netgroup
Message-ID: <20110207201202.GA3055@fieldses.org>
References: <20110207195609.GA13225@adept.internal.excfb.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110207195609.GA13225@adept.internal.excfb.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 07, 2011 at 01:56:09PM -0600, Tom Haynes wrote:
> Trying to mount:
> 
> [root@wont ~]# mount -o vers=3,hard,intr adept:/fooper /t/adept
> mount.nfs: access denied by server while mounting adept:/fooper
> [root@wont ~]# uname -a
> Linux wont.internal.excfb.com 2.6.35.10-74.fc14.x86_64 #1 SMP Thu Dec 23 16:04:50 UTC 2010 x86_64 x86_64 x86_64 GNU/Linux
> [root@wont ~]# showmount -e adept
> Export list for adept:
> /fooper @adeptya
> 
> The server tells us:
> 
> [root@adept log]# more /etc/exports 
> /fooper   @titan(rw)
> [root@adept log]# vi /etc/exports 
> [root@adept log]# more /etc/exports 
> /fooper   @adeptya(rw)
> [root@adept log]# exportfs -au
> [root@adept log]# exportfs -a
> [root@adept log]# exportfs
> /fooper       	@adeptya
> [root@adept log]# ypmatch adeptya netgroup
> (adept,,) (adept.internal.excfb.com,,) (wont,,) (wont.internal.excfb.com,,)
> [root@adept log]# host wont.internal.excfb.com
> wont.internal.excfb.com has address 192.168.2.105
> [root@adept log]# host 192.168.2.105
> 105.2.168.192.in-addr.arpa domain name pointer wont.internal.excfb.com.
> [root@adept log]# tail messages
> Feb  7 13:33:41 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
> Feb  7 13:34:58 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
> Feb  7 13:36:02 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
> Feb  7 13:36:32 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
> Feb  7 13:37:14 adept mountd[13050]: authenticated mount request from 192.168.2.105:698 for /fooper (/fooper)
> Feb  7 13:38:12 adept mountd[13050]: authenticated unmount request from 192.168.2.105:657 for /fooper (/fooper)
> Feb  7 13:39:06 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
> Feb  7 13:43:52 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
> Feb  7 13:45:24 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
> Feb  7 13:48:17 adept mountd[13050]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host
> 
> The success at 13:37:14 was from when I changed the export to:
> 
> [root@adept ~]# exportfs
> /fooper       	192.168.2.0/255.255.255.0
> 
> to verify that NFS was working. At that point I was able to mount,
> create a file, etc.
> 
> Oh yeah, the NFS server is also the NIS and DNS server, so there
> shouldn't be any connectivity issues.
> 
> What can I do to further triage this?

Alas, I've never used netgroups, much less tried to debug problems with
them.... Have you tried looking at the nis traffic over "lo" to see if
mountd's doing the right queries?  You could also try seeing if adding
"-dall" to the rpc.mountd commandline turns up any useful debugging.

After that, I don't know, I suppose I'd start looking at the mountd
source....

--b.
