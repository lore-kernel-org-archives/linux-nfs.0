Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.ij.cx ([212.13.201.15]:51314 "EHLO wes.ijneb.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755731Ab0LASSU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 13:18:20 -0500
Date: Wed, 1 Dec 2010 18:18:17 +0000 (GMT)
From: Mark Hills <mark@pogo.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: Listen backlog set to 64
In-Reply-To: <20101130200013.GA2108@fieldses.org>
Message-ID: <alpine.NEB.2.01.1012011754120.12506@jrf.vwaro.pbz>
References: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz> <20101116182026.GA3971@fieldses.org> <20101117090826.4b2724da@notabene.brown> <20101129205935.GD9897@fieldses.org> <alpine.NEB.2.01.1011301705220.26378@jrf.vwaro.pbz>
 <20101130200013.GA2108@fieldses.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 30 Nov 2010, J. Bruce Fields wrote:

> On Tue, Nov 30, 2010 at 05:50:52PM +0000, Mark Hills wrote:
[...]
> > Our investigation brings us to rpc.mountd and mount.nfs communicating. In 
> > the client log we see messages like:
> > 
> >   Nov 24 12:09:43 nyrd001 automount[3782]: >> mount.nfs: mount to NFS server 'ss1a:/mnt/raid1/banana' failed: timed out, giving up
> > 
> > Using strace and isolating one of these, I can see a non-blocking connect 
> > has already managed to make a connection and even send/receive some data. 
> > 
> > But soon a timeout of 9999 milliseconds in poll() causes a problem in 
> > mount.nfs when waiting for a response of some sort. The socket in question 
> > is a connection to mountd:
> > 
> >   26512 futex(0x7ff76affa540, FUTEX_WAKE_PRIVATE, 1) = 0
> >   26512 write(3, "\200\0\0(j\212\254\365\0\0\0\0\0\0\0\2\0\1\206\245\0\0\0\3\0\0\0\0\0\0\0\0"..., 44) = 44
> >   26512 poll([{fd=3, events=POLLIN}], 1, 9999 <unfinished ...>
> > 
> > When it returns:
> > 
> >   26512 <... poll resumed> )              = 0 (Timeout)
> >   26512 rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
> >   26512 rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
> >   26512 close(3)                          = 0
> >   26512 rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
> >   26512 write(2, "mount.nfs: mount to NFS server '"..., 100) = 100
> > 
> > There's no re-try from here, just a failed mount.
> 
> That does sound wrong.  I'm not at all familiar with automount,
> unfortunately; how is it invoking mount.nfs?
> 
> > What is the source of this 9999 millisecond timeout used by poll() in 
> > mount.nfs? It was not clear in an initial search of nfs-utils and glibc, 
> > but I need more time to investigate.
> > 
> > If the server is being too slow to respond, what could the cause of this 
> > be? Multiple threads are already in use, but it seems like they are not 
> > all in use because a thread is able to accept() the connection. I haven't 
> > been able to pin this on the forward/reverse DNS lookup used by 
> > authentication and logging.
> 
> Can you tell where the mountd threads are typically waiting?

Here's a trace from mountd. Note the long pause after fdatasync():

31156 12:09:40 open("/var/lib/nfs/rmtab", O_WRONLY|O_CREAT|O_APPEND, 0666) = 14 <0.000010>
31156 12:09:40 fstat(14, {st_mode=S_IFREG|0644, st_size=62642, ...}) = 0 <0.000005>
31156 12:09:40 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2af00c929000 <0.000007>
31156 12:09:40 fstat(14, {st_mode=S_IFREG|0644, st_size=62642, ...}) = 0 <0.000005>
31156 12:09:40 lseek(14, 62642, SEEK_SET) = 62642 <0.000006>
31156 12:09:40 write(14, "192.168.14.165:/mnt/raid1/abcde_"..., 57) = 57 <0.000013>
31156 12:09:40 fdatasync(14)            = 0 <15.413401>
31156 12:09:55 close(14)                = 0 <0.000008>
31156 12:09:55 munmap(0x2af00c929000, 4096) = 0 <0.000083>
31156 12:09:55 close(13)                = 0 <0.000008>

This pause exceeds the mysterious 9999 millisecond timeout allowed at the 
client.

fdatasync() is happening at every write of rmtab -- a lot. Occasionally it 
takes a long time. The syncing of the rmtab seems a reasonable explanation 
why more threads does not help -- all mountd threads lock up.

The strace I am analysing here contains 670 calls to fdatasync() in a 16 
minute period. All of them take < 1 second, except for this burst:

31156 12:09:11 fdatasync(14)            = 0 <0.000010>
31156 12:09:11 fdatasync(15)            = 0 <0.136285>
31156 12:09:12 fdatasync(14)            = 0 <0.000010>
31156 12:09:12 fdatasync(15)            = 0 <14.911323>
31156 12:09:27 fdatasync(14)            = 0 <1.298896>
31156 12:09:29 fdatasync(14)            = 0 <1.159262>
31156 12:09:33 fdatasync(14)            = 0 <1.447169>
31156 12:09:35 fdatasync(14)            = 0 <1.345562>
31156 12:09:40 fdatasync(14)            = 0 <0.000010>
31156 12:09:40 fdatasync(14)            = 0 <15.413401>
31156 12:09:55 fdatasync(17)            = 0 <0.000010>
31156 12:09:55 fdatasync(17)            = 0 <1.068503>
31156 12:09:57 fdatasync(18)            = 0 <0.000010>
31156 12:09:57 fdatasync(18)            = 0 <0.089682>

/var/lib/nfs/rmtab[.tmp] is on an ext3 filesystem, the system disk.

The server is only acting as a 'regular' and dedicated file server, but 
presumably some other process is causing /var to become erratic. Unless 
continual writing and syncing to a small (64KiB) file could cause this to 
happen periodically?

In the meantime we have symlink'd /var/lib/nfs/rmtab[.tmp] to a tmpfs 
mount to see if that helps, and will leave it running tonight.

-- 
Mark
