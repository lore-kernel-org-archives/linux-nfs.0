From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] [PATCH] mmap corruption
Date: Mon, 07 Apr 2003 13:39:31 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3E91B7D3.30108@RedHat.com>
References: <3E8DDB13.9020009@RedHat.com>	<shsistt7wip.fsf@charged.uio.no>	<20030405164741.GA6450@RedHat.com>	<16016.7633.982870.860147@charged.uio.no>	<20030407140052.GA1471@RedHat.com> <16017.37263.648356.201846@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: trond.myklebust@fys.uio.no
List-ID: <nfs.lists.sourceforge.net>



Trond Myklebust wrote:

>However, I still stand by my statement that nfs_wb_all() is supposed
>to ensure that *all* pending writes have been cleared.
>The only explanation for npages != 0 is if
>
>  a) an error occurred with nfs_wb_all() (we should perhaps test the
>     return value of nfs_wb_all() there). Under normal circumstances,
>     an error should only occur if you're using soft mounts, though.
>
I have checked the return value and its not failing... The would be too 
easy... :-)

SteveD.
