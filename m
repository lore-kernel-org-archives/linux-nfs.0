From: Miika Pekkarinen <miipekk@ihme.org>
Subject: Using mmap result in data corruption
Date: Fri, 12 Nov 2004 21:06:06 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0411122101130.10567@ihme.ihme.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CSgkX-0006sM-Dr
	for nfs@lists.sourceforge.net; Fri, 12 Nov 2004 11:06:21 -0800
Received: from ihme.org ([212.226.113.138] ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CSgkW-0005qh-B2
	for nfs@lists.sourceforge.net; Fri, 12 Nov 2004 11:06:21 -0800
Received: from miipekk (helo=localhost)
	by ihme.org with local-esmtp (Exim 4.24)
	id 1CSgkI-0003c8-D9
	for nfs@lists.sourceforge.net; Fri, 12 Nov 2004 21:06:06 +0200
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

Hi

(I am sending this message again to this list because my previous post
about a week ago didn't appear on this list. Now I have subscribed and I
hope for better luck. :)

I have found a reproducable issue with NFS that will lead to file
corruption on server. When a file is created with O_TRUNC and data is
copied using mmap, the new file on the server will be filled with null bytes.

NFS was exported using the following flags:
/home           *.ihme.org(rw,async,wdelay,root_squash,no_subtree_check)

This problem was reproduced with kernel versions 2.4.27 (server), 2.6.9
(server/client), 2.6.10-rc1 (client).

The included sample C-code should reproduce the problem:
	client$ gcc -o nfsdebug nfddebug.c
	client$ ./nfsdebug
	client$ ls -la nfsdebug.txt
	client$ -rw-r--r--  1 miipekk users 1393 Nov  5 23:25 nfsdebug.txt
	client$ cmp nfsdebug.txt nfsdebug.c
	client$

	server$ ls -la nfsdebug.txt
	server$ -rw-r--r--  1 miipekk users 1393 Nov  5 23:25 nfsdebug.txt
	server$ cmp nfsdebug.txt /dev/zero
	server$ cmp: EOF on nfsdebug.txt


-- 
Miika Pekkarinen <miipekk at ihme.org>


--- nfsdebug.c
/* This file should be named "nfsdebug.c".
 * After excecuted, a file named nfsdebug.txt will be created.
 *
 * Author: 2004 Miika Pekkarinen <miipekk@ihme.org>
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>

int main()
{
        int fdin, fdout;
        struct stat statbuf;
        char *s, *d;

        fdin  = open("nfsdebug.c", O_RDONLY);
        if (fdin < 0) {
                perror("open fail");
                return 1;
        }

        if (fstat(fdin, &statbuf) < 0) {
                perror("open fail");
                return 2;
        }

        fdout = open("nfsdebug.txt", O_RDWR | O_CREAT | O_TRUNC,
                     statbuf.st_mode);

        if (fdout < 0)
                return 3;

        // If the following line is enabled, the problem won't appear!
        // write(fdout, "", 1);

        if(lseek(fdout, statbuf.st_size - 1, SEEK_SET) == -1) {
                perror("Seek failed\n");
                return 4;
        }

        if (write(fdout, "", 1) != 1) {
                perror("Write failed\n");
                return 5;
        }

        if ((s = (char *)mmap(0, statbuf.st_size, PROT_READ, MAP_SHARED,
fdin, 0))
            == (caddr_t) -1) {
                perror("mmap source fail");
                return 6;
        }

        if ((d = (char *)mmap(0, statbuf.st_size, PROT_READ | PROT_WRITE,
                              MAP_SHARED, fdout, 0)) == (caddr_t) - 1) {
                perror("mmap destination fail");
                return 7;
        }

        memcpy(d, s, statbuf.st_size);

        munmap(s, statbuf.st_size);
        munmap(d, statbuf.st_size);

        close(fdin);
        close(fdout);

        return 0;
}





-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
