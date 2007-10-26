From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: 2.6.23.1 regression: write() data lost after lseek()
Date: Fri, 26 Oct 2007 17:50:39 +0200
Message-ID: <20071026155039.GA23334@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlRSI-0004qC-Ac
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 08:50:41 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlRSN-0005jA-JE
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 08:50:44 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

2.6.23.1 client (using 2.6.22.10 and 2.6.21.7 as server), mount options
according to /proc/mounts:

rw,nodev,vers=3,rsize=32768,wsize=32768,hard,intr,proto=udp,timeo=11,retrans=2,sec=sys


The data of the last write in this program gets lost when run on 2.6.23.1 client:

--------
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

int main(int argc, char **argv)
{
	int d;

	errno = 0;
	d = open(argv[1], O_CREAT|O_WRONLY|O_TRUNC, 0666);
	write(d, "a", 1);
	lseek(d, 2, SEEK_SET);
	write(d, "data lost\n", 10);
	close(d);
	perror("");
	return errno ? 1 : 0;
}
--------

$ ./prog out
Success
$ od -c out
0000000   a  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
0000014


-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
