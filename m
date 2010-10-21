Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50967 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403Ab0JUT4f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 15:56:35 -0400
Date: Thu, 21 Oct 2010 15:56:33 -0400
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS bug with utime/file create
Message-ID: <20101021195633.GG10192@fieldses.org>
References: <20101007160659.GP12489@ics.muni.cz>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101007160659.GP12489@ics.muni.cz>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 07, 2010 at 06:06:59PM +0200, Lukas Hejtmanek wrote:
> Hello,
> 
> I noticed an interesing bug in 2.6.26 kernel, not sure whether this has been
> fixed in newer version or not.
> 
> I have an application, that does basically the following code:
> int
> main(int argc, char *argv[]) {
>         int fd = open(argv[1], O_WRONLY|O_CREAT|O_TRUNC, 0666);
>         char buff[300];
>         write(fd, buff, 300);
>         while(1) {
>                 utime(argv[1], NULL);
>                 sleep(30);
>         }
>         return 0;
> }
> 
> 
> another application that runs on a different client does:
> 17:57:30.605304 nanosleep({24, 0}, {24, 0}) = 0
> 17:57:54.605526 stat64("/storage/home/xhejtman/gangadir/workspace/xhejtman/LocalXML/0",
> {st_mode=S_IFDIR|0700, st_size=59, ...}) = 0
> 17:57:54.606029 mkdir("/storage/home/xhejtman/gangadir/workspace/xhejtman/LocalXML/0/output",
> 0777) = -1 EEXIST (File exists)
> 17:57:54.606414 open("/storage/home/xhejtman/gangadir/workspace/xhejtman/LocalXML/0/output/__jobstatus__",
> O_RDONLY|O_LARGEFILE) = 3
> 17:57:54.607073 fstat64(3, {st_mode=S_IFREG|0644, st_size=300, ...}) = 0
> 17:57:54.607230 mmap2(NULL, 1048576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb74ef000
> 17:57:54.607325 _llseek(3, 0, [0], SEEK_CUR) = 0
> 17:57:54.607408 read(3, "\0\0\0\0\0\0\0\0\336e\356,\345\177\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 300
> 17:57:54.607765 read(3, "", 1048576)    = 0
> 17:57:54.607854 close(3)                = 0
> 17:57:54.608128 munmap(0xb74ef000, 1048576) = 0
> 17:57:54.608224 stat64("/storage/home/xhejtman/gangadir/workspace/xhejtman/LocalXML/0/output/__jobstatus__",
> {st_mode=S_IFREG|0644, st_size=300, ...}) = 0
> 
> The first application tries to create a file (something like:
> open("time_elapsed.txt", O_WRONLY|O_CREAT|O_TRUNC, 0666) (*)
> 
> at this point, it emits PUTFH, SAVEFH, OPEN, GETFH, GETATTR, RESTOREFH,
> GETATTR compount. The server replies with NFS4ERR_EXPIRED.
> 
> The client tries to RENEW, the server replies NFS4ERR_EXPIRED.
> 
> The client restarts using SETCLIENTID and so on. During this phase, the first
> application emits utime call. It seems that orignial open (*) get lost and system
> deadlocks. 
> 
> Using NFS debugs, I can see a warning, that the lease is not expired (from the
> client's point of view, but the server is conviced that the lease is expired).
> 
> I can reliably reproduce it with diane/ganga framework. I cannot fully reproduce it
> just using simple C programs. 
> 
> 
> Is there something I could do?

There have been a number of fixes to the client state recovery code
since then, so it may be worth just retrying with a newer kernel on the
client.

--b.
