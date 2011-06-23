Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48774 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932170Ab1FWCsM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 22:48:12 -0400
Date: Thu, 23 Jun 2011 03:48:09 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [heads-up] mknod() broken on nfs4
Message-ID: <20110623024809.GI11521@ZenIV.linux.org.uk>
References: <20110621235900.GB11521@ZenIV.linux.org.uk>
 <20110622002359.GC11521@ZenIV.linux.org.uk>
 <1308783620.25875.30.camel@lade.trondhjem.org>
 <20110622231946.GH11521@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110622231946.GH11521@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 23, 2011 at 12:19:46AM +0100, Al Viro wrote:

> It always worked that way, all the way back to Unix v6 (and I'm fairly sure
> to earlier than that; don't have v5 kernel source, unfortunately).  Worked
> that way in Linux since 0.02/0.03/0.10, when Linus first added mknod(2)
> (presumably 0.01 had been tested with /dev populated by Minix ;-)

After looking around on the net: in v3 kernel, ken/sys2.c:

mknod()
{
        int *ip;
        extern uchar;

        if(suser()) {
                ip = namei(&uchar, 1);
                if(ip != NULL) {
                        u.u_error = EEXIST;
                        goto out;
                }
        }
        if(u.u_error)
                return;
        ip = maknode(u.u_arg[1]);
        ip->i_addr[0] = u.u_arg[2];

out:
        iput(ip);
}

IOW, mknod(path, 0777, 0) will, indeed, create a regular file.  Root-only,
back then.

; ls -l ken/sys2.c 
-rw-r--r-- 1 al al 3060 Aug 30  1973 ken/sys2.c

v3 manpages don't mention mknod(2) at all; it *is* wired in syscall table
(syscall 14).  Section 2 manpages give syscall numbers; what they have for
#14 is makdir (not mentioned by that name in the kernel, described as
creating an empty directory with given pathname and mode sans . and ..
links - i.e. exactly what mknod(2) did all the way to v7 when given
S_IFDIR | something).
