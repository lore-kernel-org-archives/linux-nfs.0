From: James Pearson <james-p@moving-picture.com>
Subject: acl_extended_file() and NFS file systems
Date: Wed, 23 Jun 2004 17:11:53 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40D9ABC9.1070007@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdALw-0005kJ-Lo
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 09:12:00 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BdALw-0005NH-17
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 09:12:00 -0700
Received: from minion.mpc.local ([172.16.11.112] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.24)
	id 1BdALp-0005qK-FD
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 17:11:53 +0100
To: nfs@lists.sourceforge.net
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

We've just come across a problem with running 'ls -l' on NFS mounted 
files from a client running Fedora Core 1 with the latest coreutils RPM 
(5.0-34.1)

Running ls -l on a file exported by a RedHat 7.2 system gives

% ls -l /some/remote/file
ls: /some/remote/file: Input/output error
-rw-rw-r--  1 james user 17373 Jun  1 20:02 /some/remote/file

/var/log/messages on the client gives:

Jun 23 16:00:53 wingnut kernel: call_verify: server accept status: 1
Jun 23 16:00:53 wingnut last message repeated 2 times
Jun 23 16:00:53 wingnut kernel: RPC: garbage, exit EIO

I've tracked this down to the use of acl_extended_file() by this version 
of ls - it works OK on local file systems and NFS file systems exported 
by other FC1 machines and Solaris boxes, but gives this error on file 
systems exported by RedHat 7.2 and Irix boxes.

I can reproduce the errors with a simple bit of 'C':

#include <sys/types.h>
#include <acl/libacl.h>
#include <errno.h>

main(int argc, char **argv)
{
         int ret;

         errno = 0;
         ret = acl_extended_file (argv[1]);
         printf("ret = %d\nerrno = %d\n", ret, errno);
         exit (0);
}

(need to link with -lacl)

I've searched around and come across references to a 'noacl' option to 
mount that might help, but mount on Fedora doesn't seem to support this 
- I get:

unknown nfs mount option: noacl

I don't really know if this a real problem (I can easily fix 'ls' by 
backing out the patch to coreutils that introduces this issue), but I 
would like to understand more on what is going on ...


Thanks

James Pearson





-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
