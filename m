From: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Errors during a simple mount storm test
Date: Fri, 05 Feb 2010 02:12:51 +0530
Message-ID: <4B6B314B.4050408@gluster.com>
References: <4B6B2AE5.1070007@gluster.com> <1265315573.3317.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zp3.zcs.datasyncintra.net ([208.88.241.29]:34959 "EHLO
	zp3.zcs.datasyncintra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754673Ab0BDUmu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 15:42:50 -0500
In-Reply-To: <1265315573.3317.50.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Fri, 2010-02-05 at 01:45 +0530, Shehjar Tikoo wrote: 
>> Hi All
>>
>> The shell command below is probably not applicable to
>> all real world setups but I wanted to check it out nonetheless.
>> The problem is with the following command that is supposed
>> run a mount-umount loop:
>>
>> $ while [ true ]; do echo sending; mount localhost:/test -o 
>> noacl,nolock,tcp,mountproto=tcp /mnt;umount  /mnt; done
>>
>> For the first hundred iterations, it works fine but then starts
>> spewing errors with the mount command failing. For eg.
>> the output looks like below:
>>
>> sending
>> sending
>> sending
>> sending
>> sending
>> sending
>> sending
>> sending
>> sending
>> sending
>> sending
>> sending
>> mount.nfs: mount system call failed
>> umount: /mnt: not mounted
>> sending
>> mount.nfs: mount system call failed
>> umount: /mnt: not mounted
>> sending
>> mount.nfs: mount system call failed
>> umount: /mnt: not mounted
>> sending
>> mount.nfs: mount system call failed
>> umount: /mnt: not mounted
>>
>> Any ideas why the mount sequence stops abruptly?
>> There dont seem to be any relevant messages in the
>> dmesg output either.
>>
>> The client and server are on the same machine:
>> Linux indus 2.6.31-17-generic Ubuntu SMP x86_64 GNU/Linux
>>
>> I have verified through wireshark that the server is not
>> receiving any mount requests once the mount command start
>> failing. Instead there are only successful GETPORT requests
>> for the MOUNTv3 program.
> 
> "netstat -t" will probably show you that all your free ports in the
> range 0-1023 are now in the TIME_WAIT state. This again means that you
> have to wait a couple of minutes for the TIME_WAITs to expire before you
> can try again.
> 
> So basically, it is a case of your test being flawed.

Thanks!
I'll to resort to using noresvport in that case.

-Shehjar

> 
> Trond
> 

