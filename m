From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Errors during a simple mount storm test
Date: Thu, 04 Feb 2010 15:32:53 -0500
Message-ID: <1265315573.3317.50.camel@localhost>
References: <4B6B2AE5.1070007@gluster.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:46669 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932905Ab0BDUc6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Feb 2010 15:32:58 -0500
In-Reply-To: <4B6B2AE5.1070007-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-02-05 at 01:45 +0530, Shehjar Tikoo wrote: 
> Hi All
> 
> The shell command below is probably not applicable to
> all real world setups but I wanted to check it out nonetheless.
> The problem is with the following command that is supposed
> run a mount-umount loop:
> 
> $ while [ true ]; do echo sending; mount localhost:/test -o 
> noacl,nolock,tcp,mountproto=tcp /mnt;umount  /mnt; done
> 
> For the first hundred iterations, it works fine but then starts
> spewing errors with the mount command failing. For eg.
> the output looks like below:
> 
> sending
> sending
> sending
> sending
> sending
> sending
> sending
> sending
> sending
> sending
> sending
> sending
> mount.nfs: mount system call failed
> umount: /mnt: not mounted
> sending
> mount.nfs: mount system call failed
> umount: /mnt: not mounted
> sending
> mount.nfs: mount system call failed
> umount: /mnt: not mounted
> sending
> mount.nfs: mount system call failed
> umount: /mnt: not mounted
> 
> Any ideas why the mount sequence stops abruptly?
> There dont seem to be any relevant messages in the
> dmesg output either.
> 
> The client and server are on the same machine:
> Linux indus 2.6.31-17-generic Ubuntu SMP x86_64 GNU/Linux
> 
> I have verified through wireshark that the server is not
> receiving any mount requests once the mount command start
> failing. Instead there are only successful GETPORT requests
> for the MOUNTv3 program.

"netstat -t" will probably show you that all your free ports in the
range 0-1023 are now in the TIME_WAIT state. This again means that you
have to wait a couple of minutes for the TIME_WAITs to expire before you
can try again.

So basically, it is a case of your test being flawed.

Trond

