From: Bill Schrier <wschrier@neolinear.com>
Subject: NFS Locking Issue - Solaris-Linux
Date: Tue, 22 Oct 2002 10:08:12 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DB55BCC.447F0C32@neolinear.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------9016E5F68B3BF61B9A0247B7"
Cc: it@neolinear.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from n5.neolinear.com ([208.20.218.5] helo=flood.neolinear.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 183zjE-0003FR-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 07:09:52 -0700
Received: from ampere ([192.9.200.88])
	by flood.neolinear.com with esmtp (Exim 3.35 #1 (Debian))
	id 183zpy-0003mX-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 10:16:50 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------9016E5F68B3BF61B9A0247B7
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

We've been having a bit of trouble finding a solution to a problem we've
been having between our Solaris machines and our Raidzone machine
running Redhat (kernel 2.4.18-12smp).  I would appreciate any input on
this subject as it is basically keeping us from effectively using the
storage space we have in the Raidzone box.

The problem arises when we try to lock any file shared from the Redhat
machine from any of our Solaris machines.  This happens regardless of
the Solaris kernel version - 2.6, 8, and multiple kernel patch levels
within those OS versions.  However, with a clean install of Redhat, we
are able to successfully lock shared files - it is just this Raidzone
machine.

One major restriction is that we will be unable to recompile the kernel
on the Raidzone machine due to the extra drivers that Raidzone builds
into the kernel.  We are assuming that since we are able to successfully
lock files on other Redhat machines that it is a configuration issue,
but we've been unable to find what setting is causing the problem, and
Raidzone Technical Support has likewise been unable to locate any
differences - though they have stated that they are unable to duplicate
the problem.

I've attached a quick C program that one of our engineers here has
written to test the file locking, in case it is of any help.

Thanks in advance for any suggestions on this issue.

William Schrier

--
William J. Schrier              Phone: 412.968.5780 x151
Neolinear, Inc.                 Fax:   412.968.5788
583 Epsilon Drive               Email: wschrier@neolinear.com
Pittsburgh, PA  15238



--------------9016E5F68B3BF61B9A0247B7
Content-Type: text/plain; charset=us-ascii;
 name="lockit.cc"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lockit.cc"


#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

/* Your basic Stevens cut-and-paste */
static int
lock_reg (int fd, int cmd, int type, off_t offset, int whence, off_t
len)
{
  struct flock lock;

  lock.l_type = type; /* F_RDLCK, F_WRLCK, F_UNLCK */
  lock.l_start = offset; /* byte offset relative to whence */
  lock.l_whence = whence; /* SEEK_SET, SEEK_CUR, SEEK_END */
  lock.l_len = len; /* #bytes, 0 for eof */

  return fcntl (fd, cmd, &lock);
}

#define lock_entire_file(fd) \
  lock_reg ((fd), F_SETLK, F_WRLCK, 0, SEEK_SET, 0)
#define unlock_entire_file(fd) \
  lock_reg ((fd), F_SETLK, F_UNLCK, 0, SEEK_SET, 0)

int 
main (int argc, char **argv)
{
  int result;
  int fd;

  if (argc != 2)
    {
      fprintf (stderr, "Must pass in a single file to lock\n");
      return 1;
    }

  fd = open (argv[1], O_RDWR);
  if (fd < 0)
    {
      fprintf (stderr, "Failed to open '%s': %s\n", 
               argv[1], strerror (errno));
      return 1;
    }

  result = lock_entire_file (fd);

  if (result < 0)
    {
      fprintf (stderr, "Failed to lock '%s': %s\n",
               argv[1], strerror (errno));
      
      return 1;
    }

  printf ("Successfully locked '%s', unlocking and exiting\n",
  argv[1]);

  close (fd);
  
  return 0;
}

--------------9016E5F68B3BF61B9A0247B7--



-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4699841;7576301;v?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
