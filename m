Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36735 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753336Ab0HPKJQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Aug 2010 06:09:16 -0400
Date: Mon, 16 Aug 2010 12:09:12 +0200
Message-ID: <s5h39uedg3b.wl%tiwai@suse.de>
From: Takashi Iwai <tiwai@suse.de>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Trond.Myklebust@netapp.com, rjw@sisk.pl, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: nfs regression 2.6.35+
In-Reply-To: <20100816070626.GA10503@sli10-desk.sh.intel.com>
References: <20100816070626.GA10503@sli10-desk.sh.intel.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[Added linux-nfs to Cc]

At Mon, 16 Aug 2010 15:06:26 +0800,
Shaohua Li wrote:
> 
> NFS client runs latest git. At client side, use vim to edit a file located at
> NFS server. If I save the file, vim always reports 'E667: Fsync failed'. If I
> revert f7fa16506bf9b6323e862a61e14c20555152bb3, vim works. No kernel errors
> reported.

This hits me, too.  Reverting it cures the problem.
(BTW, the correct commit id of the affecting patch is
 af7fa16506bf9b6323e862a61e14c20555152bb3
 "NFS: Fix up the fsync code")

Reproduced on 2.6.36-rc1.

Looking at strace output, 

  open("afo", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 4
  write(4, "#!/bin\n", 7)                 = 7
  fsync(4)                                = 1
  stat("afo", {st_mode=S_IFREG|0644, st_size=7, ...}) = 0
  close(4)                                = 0

So, fsync() returns 1 wrongly.


thanks,

Takashi
