Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44085 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754522AbcK2IkS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 03:40:18 -0500
Date: Tue, 29 Nov 2016 09:40:14 +0100
From: Jan Kara <jack@suse.cz>
To: Darren Austin <lists@afterdark.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        David Howells <dhowells@redhat.com>, linux-cachefs@redhat.com
Subject: Re: BUG: User triggerable kernel panic in 4.8 (possibly 4.9)
Message-ID: <20161129084014.GA7024@quack2.suse.cz>
References: <Pine.LNX.4.64.1610201520290.25450@oraqre.bcra-fbhepr.pb.hx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.64.1610201520290.25450@oraqre.bcra-fbhepr.pb.hx>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Thanks for report. I suspect this bug got lost in the noise of
linux-kernel. Adding more relevant lists and people to CC.

								Honza

On Thu 20-10-16 15:24:37, Darren Austin wrote:
> [ Please CC me with any replies as I will be leaving the list shortly ]
> 
> Hi,
>   I'm not sure if this is the best place to report an issue i've discovered 
> with the kernel and the 'fsc' mount option - please let me know if there is 
> some other mailing list or person I should be notifying about this.
> 
> The bug appears (at least for me) when using an NFS server, and a client 
> which mounts an export from that server with the 'fsc' option (whether or 
> not the fscache daemon is running or not).  It also seems easiest to trigger 
> using the 'nano' editor, but other commands will trigger it randomly.
> 
> I've tested this bug on the Ubuntu 1610 kernel (4.8.0) and with the 4.8.2 
> kernel from http://kernel.ubuntu.com/~kernel-ppa/mainline/.  The latter 
> purports to be a kernel built from the unmodified kernel source, and simply 
> packaged in a .deb, so this isn't a Ubuntu kernel problem.  Unless the 
> problem has been corrected in the 4.9 series, I suspect the bug may also 
> persist there - i've not had the opportunity to check 4.9.x kernels as yet.
> 
> I can repeatidly reproduce this bug on my system, so it's definitely not a 
> one off - it causes a kernel panic and complete lock-up every time.
> 
> The NFS share I tested with is exported with options: 
>   rw,async,insecure,insecure_locks,no_root_squash,anongid=99,anonuid=99,no_subtree_check
> (but the export options don't seem to matter to trigger the  bug)
> and mounted on the client with options:
>   vers=4,hard,intr,acl,rw,fsc
> via the Linux automounter (but the issue persists on mounts from fstab or 
> when mounted manually).
> 
> To reproduce the bug is quite simple...
> 1) Set up the server export and client mount as detailed above.
> 2) From the console (or in a terminal; but I only tested this once) in the 
> directory where you've mounted the NFS share, run:
>   nano testfile.txt
> and add write some text to the file.
> 2) Save the file and exit (Ctl+X is how I did it).
> 3) When back at the prompt, immediately hit the up arrow on the keyboard (to
> load the last typed command into the buffer) and hit enter.
> 4) Watch as the pretty text of the panic scrolls by :)
> 
> With the help of people on the nano-dev mailing list, I figured out that 
> it's the 'fsc' option which causes the panic - repeated tests without that 
> option active do not trigger it.  However, this is /not/ a nano specific bug 
> - it can be triggered by any command used on the mount.  And besides, nano 
> shouldn't be able to take down the system :)
> 
> If any further information is required, please don't hesitate to reply.
> 
> Darren.
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
