Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52595 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280Ab0LASg7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 13:36:59 -0500
Date: Wed, 1 Dec 2010 13:36:56 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Hills <mark@pogo.org.uk>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: Listen backlog set to 64
Message-ID: <20101201183656.GB17142@fieldses.org>
References: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz>
 <20101116182026.GA3971@fieldses.org>
 <20101117090826.4b2724da@notabene.brown>
 <20101129205935.GD9897@fieldses.org>
 <alpine.NEB.2.01.1011301705220.26378@jrf.vwaro.pbz>
 <20101130200013.GA2108@fieldses.org>
 <alpine.NEB.2.01.1012011754120.12506@jrf.vwaro.pbz>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.NEB.2.01.1012011754120.12506@jrf.vwaro.pbz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 01, 2010 at 06:18:17PM +0000, Mark Hills wrote:
> Here's a trace from mountd. Note the long pause after fdatasync():
> 
> 31156 12:09:40 open("/var/lib/nfs/rmtab", O_WRONLY|O_CREAT|O_APPEND, 0666) = 14 <0.000010>
> 31156 12:09:40 fstat(14, {st_mode=S_IFREG|0644, st_size=62642, ...}) = 0 <0.000005>
> 31156 12:09:40 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2af00c929000 <0.000007>
> 31156 12:09:40 fstat(14, {st_mode=S_IFREG|0644, st_size=62642, ...}) = 0 <0.000005>
> 31156 12:09:40 lseek(14, 62642, SEEK_SET) = 62642 <0.000006>
> 31156 12:09:40 write(14, "192.168.14.165:/mnt/raid1/abcde_"..., 57) = 57 <0.000013>
> 31156 12:09:40 fdatasync(14)            = 0 <15.413401>
> 31156 12:09:55 close(14)                = 0 <0.000008>
> 31156 12:09:55 munmap(0x2af00c929000, 4096) = 0 <0.000083>
> 31156 12:09:55 close(13)                = 0 <0.000008>
> 
> This pause exceeds the mysterious 9999 millisecond timeout allowed at the 
> client.
> 
> fdatasync() is happening at every write of rmtab -- a lot. Occasionally it 
> takes a long time. The syncing of the rmtab seems a reasonable explanation 
> why more threads does not help -- all mountd threads lock up.
> 
> The strace I am analysing here contains 670 calls to fdatasync() in a 16 
> minute period. All of them take < 1 second, except for this burst:
> 
> 31156 12:09:11 fdatasync(14)            = 0 <0.000010>
> 31156 12:09:11 fdatasync(15)            = 0 <0.136285>
> 31156 12:09:12 fdatasync(14)            = 0 <0.000010>
> 31156 12:09:12 fdatasync(15)            = 0 <14.911323>
> 31156 12:09:27 fdatasync(14)            = 0 <1.298896>
> 31156 12:09:29 fdatasync(14)            = 0 <1.159262>
> 31156 12:09:33 fdatasync(14)            = 0 <1.447169>
> 31156 12:09:35 fdatasync(14)            = 0 <1.345562>
> 31156 12:09:40 fdatasync(14)            = 0 <0.000010>
> 31156 12:09:40 fdatasync(14)            = 0 <15.413401>
> 31156 12:09:55 fdatasync(17)            = 0 <0.000010>
> 31156 12:09:55 fdatasync(17)            = 0 <1.068503>
> 31156 12:09:57 fdatasync(18)            = 0 <0.000010>
> 31156 12:09:57 fdatasync(18)            = 0 <0.089682>
> 
> /var/lib/nfs/rmtab[.tmp] is on an ext3 filesystem, the system disk.
> 
> The server is only acting as a 'regular' and dedicated file server, but 
> presumably some other process is causing /var to become erratic. Unless 
> continual writing and syncing to a small (64KiB) file could cause this to 
> happen periodically?
> 
> In the meantime we have symlink'd /var/lib/nfs/rmtab[.tmp] to a tmpfs 
> mount to see if that helps, and will leave it running tonight.

I didn't really follow the controversy earlier this year about fsync
performance on ext3--is that fixed to some degree on newer kernels?

But in any case, the rmtab file is, as the rpc.mountd man page says,
"mostly ornamental".  We shouldn't be taking so much care over it.

Hm, the code in question:

	if (!have_new_cache) {
		/*
		 * If we are using the old caching interface: exportfs
		 * uses the rmtab to determine what should be exported,
		 * so it is important that it be up-to-date.
		 *
		 * If we are using the new caching interface: the rmtab
		 * is ignored by exportfs and the fdatasync only serves
		 * to slow us down.
		 */
		fflush(fp);
		fdatasync(fileno(fp));
	}

It's a little odd that you'd be hitting this case.  Do you not have "nfsd"
mounted?  (What distro is this again?)

--b.
