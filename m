From: Gabe Martin-Dempesy <gabe@mudbuginfo.com>
Subject: OSX server to Linux client: readdir() returns empty directory
Date: Mon, 20 Jun 2005 14:34:27 -0500
Message-ID: <8E7453D7-FAED-473B-A5F0-08B16994836A@mudbuginfo.com>
Mime-Version: 1.0 (Apple Message framework v730)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DkS2U-0000tQ-Mk
	for nfs@lists.sourceforge.net; Mon, 20 Jun 2005 12:34:34 -0700
Received: from ns1.orthoresident.com ([209.61.157.22] helo=www.orthoresident.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DkS2T-0007WN-QW
	for nfs@lists.sourceforge.net; Mon, 20 Jun 2005 12:34:34 -0700
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Situation:

Apple Xserve (10.3.9) was exporting its primary file share (/Volumes/ 
Sack) via read-only NFS to a Debian-woody (with 2.4.30 w/ grsecurity  
patch, to /files) with Apache 2 serving up this share as a  
DocumentRoot.  This was done to allow us to have any PHP/etc we were  
developing run in the same environment as our production server,  
while allowing all the file sharing to occur on the Xserve.  This  
setup worked without any hitches.

We upgraded the Xserve to tiger after waiting for the 10.4.1 patch to  
come out (to hopefully have any critical issues ironed out) and NFS  
started acting strange.  Please note that none of these issues  
involving hanging, or a looping getdents (which is the closest linux/ 
osx NFS issue involving readdir() which I've run into)


Issues:
* First thing we noticed was that Apache2's file listings, created by  
mod_autoindex -- the default module that creates directory listings,  
started pulling up all directories as if they were empty.  Typing in  
absolute paths to files still worked
* Bash's tab-completion stopped working on the /files mount on the  
Debian machine.
* Suspecting an issue with readdir(), I wrote this sample PHP applet  
to verify my hunch with readdir().  Code follows:
<?php
$dir = '/files';

if ($handle = opendir($dir)) {
    echo "dir opened fine\n";
    while (false !== ($file = readdir($handle))) {
       echo "$file\n";
    }
    closedir($handle);
} else {
    echo "could not open dir\n";
}
?>
Output:
dir opened fine
.
..
* A sample C program doing the same thing also didn't work.  Code:
/*
* readdir.c: example usage for opendir()/readdir()/closedir()
*
* Matt Dailey, Feb 2004
*
* Compile with "gcc readdir.c" to get executable a.out.
*
* This example program prints out the files in the current
* directory
*
* Be sure to refer to "man 3 readdir" etc.
*
*/

#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

int main( int argc, char *argv[] ) {
     DIR *pDIR;
     struct dirent *pDirEnt;

     /* Open the current directory */

     pDIR = opendir("/files");

     if ( pDIR == NULL ) {
         fprintf( stderr, "%s %d: opendir() failed (%s)\n",
                  __FILE__, __LINE__, strerror( errno ));
         exit( -1 );
     }

     /* Get each directory entry from pDIR and print its name */

     pDirEnt = readdir( pDIR );
     while ( pDirEnt != NULL ) {
         printf( "%s\n", pDirEnt->d_name );
         pDirEnt = readdir( pDIR );
     }

     /* Release the open directory */

     closedir( pDIR );

     return 0;
}
Output:
.
..

Things that still worked:
* (GNU's) `ls` worked fine.  I downloaded the GNU fileutils 4.1  
source to examine the source to `ls`, and its only readdir() call  
looks very similar to the above C snippet.  From ls.c:1778
--snip--
   while ((next = readdir (reading)) != NULL)
     if (file_interesting (next))
       {
         enum filetype type = unknown;

#if HAVE_STRUCT_DIRENT_D_TYPE
         if (next->d_type == DT_DIR || next->d_type == DT_CHR
             || next->d_type == DT_BLK || next->d_type == DT_SOCK
             || next->d_type == DT_FIFO)
           type = next->d_type;
#endif
         total_blocks += gobble_file (next->d_name, type, 0, name);
       }

   if (CLOSEDIR (reading))
     {
       error (0, errno, "%s", quotearg_colon (name));
       exit_status = 1;
       /* Don't return; print whatever we got. */
     }
--snip--
* A Perl program basically equilvilent to the above PHP program  
worked fine.
#!/usr/bin/perl

use strict;

my $path = '/files/';
opendir(DIR, $path) || die "can not opendir $path";
my @files = readdir(DIR);
closedir DIR;

my $file;
foreach $file (sort @files) {
         print $file, "\n";
}
Output:
.
..
.DS_Store
.FBCIndexCopy
.FBCLockFolder
.TemporaryItems
.Trashes
.VolumeIcon.icns
Abernathie
About Joints
BBK
(etc..)
* After restarting `portmap` and remounting the file share (to  
hopefully eliminate any cacheing), watching a `tcpdump` while any of  
the above non-working programs execute clearly displays all the  
directories being transmitted in the raw traffic.  Note that I was  
just running with `tcpdump -x -s 0 src host xserve`, so if there is a  
better way to execute that as to get more meaningful NFS debugging  
with that, I'd like to give it a shot.
* EVERYTHING works fine using a separate OSX machine as a client.


Other systems reproduced on:
Suspecting that this was an issue with Debian-woody being outdated as  
all hell, I installed a new server with a fresh copy of Gentoo  
2005.0, with a 2.6 kernel and all recent versions of userland  
programs (like portmap).  This resulted in identical behavior to all  
of the successes and failures listed above, except for bash  
completion, which worked on the gentoo machine.


I'm really not sure where this is to blame, so I'm probably going to  
end up  cross posting this to a lot of places.  Maybe OSX Server is  
actually complying to the protocol, and the latest upgrade triggered  
something broken in the kernel.  Maybe this is some weird compile- 
time option dealing with glibc. for these apps that is controlling  
the 'do I break or not' behavior; I suspect glibc could be involved  
due to the getdents behavior listed in the following straces:


Appendix:
`straces` and `ldd`s for all the programs above which succeeded and  
failed

* "strace php -f readdir-test.php" -- This program did not work; note  
the llseek
open("/files", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 3
fstat64(3, {st_mode=S_IFDIR|0775, st_size=2278, ...}) = 0
fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
fstat64(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,  
-1, 0) = 0x52b26000
write(1, "dir opened fine\n", 16dir opened fine
)       = 16
getdents64(3, /* 64 entries */, 32768)  = 2168
_llseek(3, 2, [2], SEEK_SET)            = 0
write(1, ".\n", 2.
)                      = 2
write(1, "..\n", 3..
)                     = 3
getdents64(3, /* 62 entries */, 32768)  = 2120
close(3)                                = 0
-- and the ldd --
         libsablot.so.0 => /usr/lib/libsablot.so.0 (0x24380000)
         libstdc++.so.5 => /usr/lib/gcc-lib/i386-pc-linux-gnu/ 
3.3.5-20050130/libstdc++.so.5 (0x24477000)
         libexpat.so.0 => /usr/lib/libexpat.so.0 (0x2458e000)
         libhistory.so.5 => /lib/libhistory.so.5 (0x245b7000)
         libreadline.so.5 => /lib/libreadline.so.5 (0x245c1000)
         libncurses.so.5 => /lib/libncurses.so.5 (0x245f7000)
         libpanel.so.5 => /usr/lib/libpanel.so.5 (0x24640000)
         libmysqlclient.so.14 => /usr/lib/libmysqlclient.so.14  
(0x24645000)
         libmhash.so.2 => /usr/lib/libmhash.so.2 (0x24770000)
         libmcrypt.so.4 => /usr/lib/libmcrypt.so.4 (0x247a9000)
         libltdl.so.3 => /usr/lib/libltdl.so.3 (0x247e5000)
         libexslt.so.0 => /usr/lib/libexslt.so.0 (0x247ee000)
         libgcrypt.so.11 => /usr/lib/libgcrypt.so.11 (0x24803000)
         libgpg-error.so.0 => /usr/lib/libgpg-error.so.0 (0x2485c000)
         libz.so.1 => /lib/libz.so.1 (0x24861000)
         libm.so.6 => /lib/libm.so.6 (0x24875000)
         libxslt.so.1 => /usr/lib/libxslt.so.1 (0x24897000)
         libdb-4.2.so => /usr/lib/libdb-4.2.so (0x248d1000)
         libdb.so.2 => /usr/lib/libdb.so.2 (0x249ca000)
         libbz2.so.1.0 => /usr/lib/libbz2.so.1.0 (0x249dc000)
         libresolv.so.2 => /lib/libresolv.so.2 (0x249ed000)
         libxmlparse.so.0 => /usr/lib/libxmlparse.so.0 (0x24a01000)
         libxmltok.so.0 => /usr/lib/libxmltok.so.0 (0x24a0d000)
         libcrypt.so.1 => /lib/libcrypt.so.1 (0x24a25000)
         libnsl.so.1 => /lib/libnsl.so.1 (0x24a53000)
         libssl.so.0.9.7 => /usr/lib/libssl.so.0.9.7 (0x24a69000)
         libcrypto.so.0.9.7 => /usr/lib/libcrypto.so.0.9.7 (0x24aa0000)
         libxml2.so.2 => /usr/lib/libxml2.so.2 (0x24bd4000)
         libdl.so.2 => /lib/libdl.so.2 (0x24d12000)
         libpthread.so.0 => /lib/libpthread.so.0 (0x24d16000)
         libc.so.6 => /lib/libc.so.6 (0x24d68000)
         libgcc_s.so.1 => /usr/lib/gcc-lib/i386-pc-linux-gnu/ 
3.3.5-20050130/libgcc_s.so.1 (0x24e7b000)
         /lib/ld-linux.so.2 (0x2436a000)

* "strace ./rd" (c implementation) -- This program did not work; note  
the llseek
open("/files", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 3
fstat64(3, {st_mode=S_IFDIR|0775, st_size=2278, ...}) = 0
fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
brk(0)                                  = 0x12672ee0
brk(0x12693ee0)                         = 0x12693ee0
brk(0x12694000)                         = 0x12694000
getdents64(3, /* 64 entries */, 32768)  = 2168
_llseek(3, 2, [2], SEEK_SET)            = 0
fstat64(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,  
-1, 0) = 0x5713e000
write(1, ".\n", 2.
)                      = 2
write(1, "..\n", 3..
)                     = 3
getdents64(3, /* 62 entries */, 32768)  = 2120
brk(0x12693000)                         = 0x12693000
close(3)                                = 0
-- and the ldd --
         libc.so.6 => /lib/libc.so.6 (0x21b88000)
         /lib/ld-linux.so.2 (0x21b72000)

*  "strace perl readdir-test.pl" -- This program worked; note the two  
successive getdents
open("/files/", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 3
fstat64(3, {st_mode=S_IFDIR|0775, st_size=2278, ...}) = 0
fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
getdents64(3, /* 64 entries */, 32768)  = 2168
getdents64(3, /* 0 entries */, 32768)   = 0
close(3)
-- and the ldd --
         libpthread.so.0 => /lib/libpthread.so.0 (0x25d85000)
         libnsl.so.1 => /lib/libnsl.so.1 (0x25dd7000)
         libdl.so.2 => /lib/libdl.so.2 (0x25ded000)
         libm.so.6 => /lib/libm.so.6 (0x25df1000)
         libcrypt.so.1 => /lib/libcrypt.so.1 (0x25e13000)
         libutil.so.1 => /lib/libutil.so.1 (0x25e41000)
         libc.so.6 => /lib/libc.so.6 (0x25e45000)
         /lib/ld-linux.so.2 (0x25d6f000)

* "strace ls /files" -- This program worked; note the two successive  
getdents
open("/files", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 3
fstat64(3, {st_mode=S_IFDIR|0775, st_size=2278, ...}) = 0
fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
getdents64(3, /* 64 entries */, 32768)  = 2168
getdents64(3, /* 0 entries */, 32768)   = 0
close(3)                                = 0
-- and the ldd --
         librt.so.1 => /lib/librt.so.1 (0x225ca000)
         libncurses.so.5 => /lib/libncurses.so.5 (0x225dd000)
         libc.so.6 => /lib/libc.so.6 (0x22626000)
         libpthread.so.0 => /lib/libpthread.so.0 (0x22739000)
         /lib/ld-linux.so.2 (0x225b4000)


I've switched the server over to SMBFS until I can figure out what's  
causing the problem, but I feel like this is probably a small gotcha  
that is seldom encountered.

-- Gabe


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
