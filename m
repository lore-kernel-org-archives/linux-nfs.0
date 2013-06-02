Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4450 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752934Ab3FBU4G convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Jun 2013 16:56:06 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: William Dauchy <wdauchy@gmail.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: nfsv4 mount with noexec
Date: Sun, 2 Jun 2013 20:56:04 +0000
Message-ID: <1370206557.46256.12.camel@leira.trondhjem.org>
References: <CAJ75kXa858MgWZ5A5dt+EswJyR4rJx1ke5Siv8hxds5FPJz_ww@mail.gmail.com>
In-Reply-To: <CAJ75kXa858MgWZ5A5dt+EswJyR4rJx1ke5Siv8hxds5FPJz_ww@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2013-06-01 at 13:33 +0200, William Dauchy wrote:
> Hello,
> 
> I've been testing a nfsv4 client based on a 3.8.13 kernel with the
> following additional patches:
> a3c3cac SUNRPC: Prevent an rpc_task wakeup race
> f448bad NFSv4: Fix a thinko in nfs4_try_open_cached
> eb54d43 NFS: Fix security flavor negotiation with legacy binary mounts
> 
> the mount options are:
> type nfs4
> rw,nosuid,nodev,noexec,noatime,nodiratime,vers=4.0,rsize=32768,wsize=32768,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,local_lock=none
> 
> Even with the noexec option, I'm still able to execute local binaries
> on the mounted file system.
> Am I wrong on something? I didn't had the issue on a 3.4.x

The mount level flags such as 'nosuid', 'nodev' and 'noexec' are
supposed to be enforced by the VFS, and not by the NFS code. The check
is supposedly done in fs/exec.c:open_exec() after the file has been
opened by the filesystem.

Does 'cat /proc/mounts' actually show the noexec option being applied to
the mountpoint by the kernel?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
