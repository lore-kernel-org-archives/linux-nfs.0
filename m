From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: corruption over NFS with 2.6 client, locking, truncating and appending...
Date: Tue, 5 Apr 2005 10:51:42 +1000
Message-ID: <16977.57630.766727.608029@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIcgw-00032j-Ta
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 18:17:18 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DIcgv-00062Q-Sk
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 18:17:18 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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


(hope there are a suitable number of keywords in the subject...)

(I have already exchanged a couple of Emails with Trond which were
meant to be cc:ed to the list, but due to clumsiness on my part,
weren't). 


I'm getting quite a bit of mailbox corruption on mailboxes accessed
over NFS (both for delivery and mail client access).   This seemed to
start happening (or start getting worse) when we upgraded some client
machines to 2.6.

I can now reproduce various sorts of corruption using a test program
which follows.
The test machines I have used either run 2.6.11.2 or 2.4.26.

The NFS server is running 2.4.26 in all cases.  I'm using hard,
interruptible, udp, v3 NFS mounts with rsize=wsize=8192

The test involves running a small program on each of two different
clients.

On one client, the program locks a named file, appends a 10 byte
string which reports what it thinks is the size of the file, and then
unlocks the file.  It does this repeatedly.  You can control the
speed.

On the other client, the program locks the same file, reads the last
10 byte record, and truncates the file to remove that record.

This should result in a file that always contains 10byte records each
of which records it's own position in the file.  Depending on the
relative speeds of the client programs, the file may grow or shrink,
or hover.

The program can use either lockf (aka fcntl) locking or lockfile
locking (where a file is hardlinked to file.lock, thus providing
exclusive access even over NFS).

When lockfile locking is used, the actual file is opened after the
lockfile is successfully created, so the close-to-open consistency of
NFS should protect the contents (I think).

I have only tested with the truncating program running on a 2.4
kernel.  The appending program has run on both 2.4 and 2.6.

The results: 
  In each case, the read/truncate goes slightly slower than the
  append, so the file grows slowly

Append on 2.4, truncate on 2.4

   .lock file locking

       Some of the (10 bytes) records in the file appear as 10 nuls
       instead of the expected content.
       I vaguely recall that 2.4 doesn't have full CTO support, so
       this might be expected.

   lockf locking

       No nuls appear in the file, but sometimes the records have the
       wrong value. For example, the following is a excerpt from the
       test file in such a case:

000004100
000004110
000004120
000004130
000004140
000004160
000004160
000004170
000004180
000004190
000004200

       Note that what should be 4150 is 4160
       This certainly seems wrong to me, but isn't my current problem.

       I find these errors I use the following awk line:

       % awk '{if ($1-t != 10) print $1 ; t=$1}' test-file


Append on 2.6, truncate on 2.4

     .lock file locking

       partial records appear as nuls, always at the end of a block.
       e.g. (as displayed by less).
000004050
000004060
000004070
^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@090
000004100
000004110

       The last nul is the 4095th byte of the file.

       I think this might be part of my problem.


    lockf locking

       Whole 10byte records get replaced by nuls.  
       e.g. (Again shown by 'less')

000005800
000005810
000005820
^@^@^@^@^@^@^@^@^@^@000005840
000005850
000005860
000005870
^@^@^@^@^@^@^@^@^@^@000005890
000005900
000005910
000005920

        I think this is the rest of my problem.


Note that whenever I look at the file to check for nuls,
I do it on the file server, not over NFS.


So: 
   Is there something wrong with my code?  
    or wrong with my expectations?
   Can anyone else reproduce any of this? with other kernel versions?
   Where would I look to find the problem?
   If there a patch available?

Thanks,
NeilBrown

My test program:
  First arg is 'a' to append or 't' to truncate.
  Second is 'f' for lockf locking and 'l' for lock-file locking
  Third is microseconds to sleep between accesses
  Fourth is name of file.




-----------------------------------------------------------------------------
/*
 * test nfs/mail problem
 *
 * This should be run on two clients in the same NFS mounted
 * directory.
 * On one client it should repeatedly append to the file
 * On the other it should repeatedly read and truncate the last entry
 *
 * Locking can either be lockfile 'l' or fcntl 'f'
 *
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

void file_lockit(char *name)
{
	char tnm[100];
	char lnm[100];

	sprintf(tnm, "%s.lock-%d", name, getpid());
	sprintf(lnm, "%s.lock", name);
	while(1) {
		int fd = open(tnm, O_RDWR|O_CREAT,0600);
		if (fd < 0)
			continue;
		close(fd);
		if (link(tnm, lnm)== 0) {
			unlink(tnm);
			return;
		}
		unlink(tnm);
	}
}

void file_unlockit(char*name)
{
	char lnm[100];

	sprintf(lnm, "%s.lock", name);
	unlink(lnm);
}


main(int argc, char*argv[])
{
	char *locktype, *action, *file;
	unsigned long usecs;
	char buf[20];
	long off;
	int fd;

	if (argc != 5) {
		fprintf(stderr,"Usage: tst [at] [lf] sleep-microseconds file\n");
		exit(1);
	}
	locktype = argv[2];
	action = argv[1];
	usecs = atol(argv[3]);
	file = argv[4];
	while(1) {
		usleep(usecs);

		if (strchr(locktype, 'l'))
			file_lockit(file);

		fd = open(file, *action=='t' ? O_RDWR|O_CREAT : O_WRONLY|O_CREAT|O_APPEND, 0600);

		if (strchr(locktype, 'f')) {
			if (lockf(fd, F_LOCK, 0) < 0) {
				close(fd);
				if (strchr(locktype, 'l'))
					file_unlockit(file);
				continue;
			}
		}

		switch(*action) {
		case 'a': /* append */
			off = lseek(fd, 0, SEEK_END);
			sprintf(buf, "%09lu\n", off);
			write(fd, buf, 10);
			fsync(fd);
			break;
		case 't': /* truncate */
			off = lseek(fd, -10, SEEK_END);
			if (off <= 0) {
				printf("?");
			} else {
				read(fd, buf, 10);
				ftruncate(fd, off);
				fsync(fd);
				if (buf[0] == 0) 
					printf(".");
			}
			break;
		default:
			if (strchr(locktype, 'l'))
				file_unlockit(file);
			printf("Bad action: %s\n", action);
			exit(1);
		}

		if (strchr(locktype, 'f'))
			lockf(fd, F_ULOCK, 0);

		close(fd);
		if (strchr(locktype, 'l'))
			file_unlockit(file);
	}
}


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
