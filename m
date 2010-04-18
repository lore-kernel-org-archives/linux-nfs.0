From: Nix <nix@esperi.org.uk>
Subject: Re: 2.6.34rc4 NFS writeback regression (bisected): client often fails to delete things it just created
Date: Sun, 18 Apr 2010 22:09:11 +0100
Message-ID: <87iq7oa2o8.fsf@spindle.srvr.nix>
References: <87tyr9dfvv.fsf@spindle.srvr.nix>
	<1271618484.8049.1.camel@localhost.localdomain>
	<87vdboa7e0.fsf@spindle.srvr.nix>
	<1271620750.8049.3.camel@localhost.localdomain>
	<87mxx0a5pc.fsf@spindle.srvr.nix>
	<1271621624.8049.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:53637 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab0DRVJX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Apr 2010 17:09:23 -0400
In-Reply-To: <1271621624.8049.6.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org> (Trond Myklebust's message of "Sun, 18 Apr 2010 16:13:44 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18 Apr 2010, Trond Myklebust outgrape:
> OK. Next question is how these files are being written. If you 'strace'
> the process, do you see ordinary write() calls being used, or is the
> file perhaps being written via mmap()?

(strace output is at
<http://www.esperi.org.uk/~nix/temporary/strace-kdelibs-nfs-EBUSY.log.lzma>
if you want to look for yourself, but it's about 70Mb unlzmaed, so I can
understand if you run very fast in the opposite direction...)

The files are all ELF object files:

build/CMakeFiles/CMakeTmp/CMakeFiles/cmTryCompileExec.dir/.nfs000000000031c7510000159b: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), stripped

... which means they're being written by gas, and that writes them out
with write() (it's easy to spot gas writing things out, because one
of the first things it writes is an ELF note of the general form
"GCC: (GNU) 4.4.4" which is very rare elsewhere in an strace dump.)

A complete as run looks like this (I think this is one of the failing
ones, only of course it's cmake's subsequent recursive unlink()/rmdir()
that fails: I speculate that the non-failing ones only work because they
ran early enough that writeback had completed for them...):

23109 mmap(NULL, 528384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fafe3703000
23109 mmap(NULL, 528384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fafe3682000
23109 mmap(NULL, 528384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fafe3601000
23109 mmap(NULL, 528384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fafe29f7000
23109 stat("CMakeFiles/cmTryCompileExec.dir/src.cxx.o", 0x7fffe1073b40) = -1 ENOENT (No such file or directory)
23109 open("CMakeFiles/cmTryCompileExec.dir/src.cxx.o", O_RDWR|O_CREAT|O_TRUNC, 0666) = 3
23109 fcntl(3, F_GETFD)                 = 0
23109 fcntl(3, F_SETFD, FD_CLOEXEC)     = 0
23109 mmap(NULL, 528384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fafe2976000
23109 brk(0x1006000)                    = 0x1006000
23109 mmap(NULL, 528384, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fafe28f5000
23109 open("/tmp/ccybr1Xe.s", O_RDONLY) = 4
23109 fstat(4, {st_mode=S_IFREG|0600, st_size=356, ...}) = 0
23109 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fafe37b3000
23109 read(4, "\t.file\t\"src.cxx\"\n\t.text\n.globl m"..., 4096) = 356
23109 read(4, "", 28672)                = 0
23109 read(4, "", 32768)                = 0
23109 read(4, "", 32768)                = 0
23109 close(4)                          = 0
23109 munmap(0x7fafe37b3000, 4096)      = 0
23109 brk(0x102a000)                    = 0x102a000
23109 fstat(3, {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
23109 mmap(NULL, 1048576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fafe27f5000
23109 lseek(3, 0, SEEK_SET)             = 0
23109 read(3, "", 1184)                 = 0
23109 lseek(3, 1184, SEEK_CUR)          = 1184
23109 write(3, "\0src.cxx\0main\0", 14) = 14
23109 lseek(3, 0, SEEK_SET)             = 0
23109 read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1198
23109 lseek(3, -1134, SEEK_CUR)         = 64
23109 write(3, "UH\211\345\270\0\0\0\0\311\303", 11) = 11
23109 lseek(3, 0, SEEK_SET)             = 0
23109 read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1198
23109 lseek(3, -1122, SEEK_CUR)         = 76
23109 write(3, "\0GCC: (GNU) 4.4.4 20100308 (prer"..., 40) = 40
23109 lseek(3, 0, SEEK_SET)             = 0
23109 read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1198
23109 lseek(3, -1078, SEEK_CUR)         = 120
23109 write(3, "\24\0\0\0\0\0\0\0\1zR\0\1x\20\1\33\f\7\10\220\1\0\0\34\0\0\0\34\0\0\0"..., 56) = 56
23109 lseek(3, 0, SEEK_SET)             = 0
23109 read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1198
23109 lseek(3, 2, SEEK_CUR)             = 1200
23109 write(3, " \0\0\0\0\0\0\0\2\0\0\0\2\0\0\0\0\0\0\0\0\0\0\0", 24) = 24
23109 lseek(3, 0, SEEK_SET)             = 0
23109 read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1224
23109 lseek(3, -256, SEEK_CUR)          = 968
23109 write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\0\0\0\4\0\361\377"..., 216) = 216
23109 lseek(3, 0, SEEK_SET)             = 0
23109 read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1224
23109 lseek(3, -1048, SEEK_CUR)         = 176
23109 write(3, "\0.symtab\0.strtab\0.shstrtab\0.text"..., 84) = 84
23109 lseek(3, 0, SEEK_SET)             = 0
23109 write(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\1\0>\0\1\0\0\0\0\0\0\0\0\0\0\0"..., 64) = 64
23109 lseek(3, 0, SEEK_SET)             = 0
23109 read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\1\0>\0\1\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1224
23109 brk(0x1021000)                    = 0x1021000
23109 lseek(3, -960, SEEK_CUR)          = 264
23109 write(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 704) = 704
23109 close(3)                          = 0
23109 munmap(0x7fafe27f5000, 1048576)   = 0
23109 exit_group(0)                     = ?

However, this can't be the whole picture, because this does *not* fail:

mkdir foo; (cd foo; echo 'int main (void) {}' | c++ -x c++ -c -o foo.o -pipe -); rm -r foo

So it's something more than just as.

I wonder if the failures are caused by ld -r invocations?

... no, there are none: the relict files must therefore be the result of
'as' runs. It's a shame I can't tell what they were called before they
were deleted...
