From: Peter Staubach <staubach@redhat.com>
Subject: Re: inode caching
Date: Tue, 27 May 2008 08:48:27 -0400
Message-ID: <483C031B.80601@redhat.com>
References: <1211835499.3904.231.camel@hurina>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: linux-nfs@vger.kernel.org
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44168 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756809AbYE0Msc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 May 2008 08:48:32 -0400
In-Reply-To: <1211835499.3904.231.camel@hurina>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Timo Sirainen wrote:
> NFS server: Linux 2.6.25
> NFS client: Linux debian 2.6.25-2 (or 2.6.23.1)
>
> If I do:
>
> NFS client: fd1 =3D creat("foo"); write(fd1, "xx", 2); fsync(fd1);
> NFS server: unlink("foo"); creat("foo");
> NFS client: fd2 =3D open("foo"); fstat(fd1, &st1); fstat(fd2, &st2);
> fstat(fd1, &st3);
>
> The result is usually that the fstat(fd1) fails with ESTALE. But
> sometimes the result is st1.st_ino =3D=3D st2.st_ino =3D=3D st3.st_in=
o and
> st1.st_size =3D=3D 2 but st2.st_size =3D=3D 0. So I see two different=
 files
> using the same inode number. I'd really want to avoid seeing that
> condition.
>
>  =20

This is really up the file system on the server. It is the one
that selects the inode number when creating a new file.

> So what I'd want to know is:
>
> a) Why does this happen only sometimes? I can't really figure out fro=
m
> the code what invalidates the fd1 inode. Apparently the second open()
> somehow, but since it uses the new "foo" file with a different struct
> inode, where does the old struct inode get invalidated?
>
>  =20

This will happen always, but you may see occasional successful
fstat() calls on the client due to attribute caching and/or
dentry caching.

> b) Can this be fixed? Or is it just luck that it works as well as it
> does now?
>
>  =20

This can be fixed, somewhat. I have some changes to address the
ESTALE situation in system calls that take filename as arguments,
but I need to work with some more people to get them included.
The system calls which do not take file names as arguments can not
be recovered from because the file they are referring is really
gone or at least not accessible anymore.

The reuse of the inode number is just a fact of life and that way
that file systems work. I would suggest rethinking your application
in order to reduce or eliminate any dependence that it might have.

All this said, making changes on both the server and the client is
dangerous and can easily to lead to consistency and/or performance
issues.

Thanx...

ps


> =EF=BB=BFAttached a test program. Usage:
>
> NFS client: Mount with actimeo=3D2
> NFS client: ./t
> (Run the next two commands within 2 seconds)
> NFS server: rm -f foo;touch foo
> NFS client: hit enter=20
>
> Once in a while the result will be:
> 1a: ino=3D15646940 size=3D2
> 1b: ino=3D15646940 size=3D2
> 1c: ino=3D15646940 size=3D2
> 2: ino=3D15646940 size=3D0
> 1d: ino=3D15646940 size=3D2
>
>  =20
> ---------------------------------------------------------------------=
---
>
> #include <errno.h>
> #include <string.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <stdio.h>
> #include <sys/stat.h>
>
> int main(void) {
> 	struct stat st;
> 	int fd, fd2;
> 	char buf[100];
>
> 	fd =3D open("foo", O_RDWR | O_CREAT, 0666);
> 	write(fd, "xx", 2); fsync(fd);
> 	if (fstat(fd, &st) < 0) perror("fstat()");
> 	printf("1a: ino=3D%ld size=3D%ld\n", (long)st.st_ino, st.st_size);
>
> 	fgets(buf, sizeof(buf), stdin);
> 	if (fstat(fd, &st) < 0) perror("fstat()");
> 	else printf("1b: ino=3D%ld size=3D%ld\n", (long)st.st_ino, st.st_siz=
e);
>
> 	fd2 =3D open("foo", O_RDWR);
> 	if (fstat(fd, &st) < 0) perror("fstat()");
> 	else printf("1c: ino=3D%ld size=3D%ld\n", (long)st.st_ino, st.st_siz=
e);
> 	if (fstat(fd2, &st) < 0) perror("fstat()");
> 	else printf("2: ino=3D%ld size=3D%ld\n", (long)st.st_ino, st.st_size=
);
> 	if (fstat(fd, &st) < 0) perror("fstat()");
> 	else printf("1d: ino=3D%ld size=3D%ld\n", (long)st.st_ino, st.st_siz=
e);
> 	return 0;
> }
>  =20

