From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Fri, 5 Sep 2008 15:56:46 -0400
Message-ID: <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com>
References: <20080905191939.GG22796@merfinllc.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML Kernel <linux-kernel@vger.kernel.org>
To: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:16301 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbYIET5T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 15:57:19 -0400
In-Reply-To: <20080905191939.GG22796-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[ replacing cc: nfs-qX0GgiIySws@public.gmane.org with linux-nfs@vger.kernel.org, and neil's  
old address with his current one ]

On Sep 5, 2008, at Sep 5, 2008, 3:19 PM, Aaron Straus wrote:
> Hi all,
>
>  We're hitting some bad behavior in NFS v3.  The situation is this:
>
>   machine A - NFS server
>
>   machine B - NFS client (writer)
>   machine C - NFS client (reader)
>
>   (all machines x86 SMP)
>
>  machine A exports a directory on ext3 filesystem:
>
> 	/srv/home       192.168.0.0/24(rw,sync,no_subtree_check)
>
>  machines B and C mount that directory normally
>
>        mount A:/srv/home /mntpnt
>
>  machine B opens a file and writes to it (think a log file)
>
>  machine C stats that file, opens it and reads it (think tailing the
>                                                    log file)
>
>
>  The issue is that machine C will often see large blocks of NULLs
> (zeros) in the file.  If you do the same read again just after you see
> the block of NULLs you will see proper the data.
>
>  Attached are two simple python programs that demonstrate the problem.
>
>  To use them (they will write to a file called test-nfs in CWD):
>
> (on machine B in one window)
>
>   python writer.py
>
> (on machine C in another window)
>
>   python reader.py
>
>
>  reader.py will die when it sees NULLs in the file.  Usually for us
> this happens after about 60s (two timeouts I think).   The first  
> NULL is
> usually either at index 4000 or 8000 depending on the kernel.
>
>
>  Now the version of the kernel the server is running doesn't seem to
> matter.  The reader also doesn't seem to matter (though I didn't test
> this completely).  The writer seems to be the issue:
>
>  Writer_Version     Outcome:
>  <= 2.6.19          OK
>  >= 2.6.20	    BAD

Up to which kernel?  Recent ones may address this issue already.

>  I've tested both vanilla kernel.org kernels and Ubuntu 8.04 kernels.
>
>  I can try to bisect between 2.6.19 <-> 2.6.20.

That's a good start.

Comparing a wire trace with strace output, starting with the writing  
client, might also be illuminating.  We prefer wireshark as it uses  
good default trace settings, parses the wire bytes and displays them  
coherently, and allows you to sort the frames in various useful ways.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
