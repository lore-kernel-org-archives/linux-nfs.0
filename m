From: Jeff Garzik <jeff@garzik.org>
Subject: A new NFSv4 server...
Date: Thu, 03 Jan 2008 07:16:49 -0500
Message-ID: <477CD231.30603@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: nfsv4@linux-nfs.org, NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46685 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbYACMQx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2008 07:16:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In case some developers are interested...  I'm poking at a from-scratch 
userland NFSv4 server, as a side project.

In my personal opinion, version 4 of NFS is a quantum-leap improvement 
over previous versions.  While I used NFS v3 extensively, I always felt 
it was a crappy protocol, and unworthy of serious development effort. 
That changed with v4.

I chose to use NFSv4 as the basis for experiments (hopefully yielding 
production software) that I've long wanted to do in reliable 
filesystems, distributed filesystems, and other fun areas.

In the first step down this long path, I've created an NFSv4 userland 
server from scratch.  Currently it merely serves data straight from RAM, 
but the long term goal is to permit modular storage backends.  Thus you 
could implement a simple RAM backend, an sqlite-based backend or a 
complex distributed storage backend.

As this is a first-mention developer-only announcement, I didn't bother 
to create source tarballs.  Here is the git repo:
	git://git.kernel.org/pub/scm/daemon/nfs/nfs4-ram.git

This is the home page, but it's mainly a stub pointing to the git repo:
	http://linux.yyz.us/projects/nfsv4.html

The server will
* serve data from RAM, with NFSv4 persistent filehandles and FILE_SYNC4
* destroy all data, when the process exits
* pass 97% of the useful pynfs tests (cvs latest)
* pass fsx-linux stress testing, with Linux NFSv4 client (2.6.recent)
* pass kernel build stress testing, with Linux NFSv4 client (2.6.recent)

It will not, at the present time,
* store any data or metadata in stable storage
* do RPCSEC_GSS (thus, not yet RFC-compliant)
* do delegations (thus, with reduced caching and increased 
revalidations, can be slower than disk-based storage)

At this point, I'm quite interested to hear feedback on how the server 
works with other NFSv4 clients.  I'm interested in making sure the 
server is portable to FreeBSD and other OS's, even though it was 
developed and tested only on Linux.  I also intend to use some 
Linux-specific syscalls, most notably sync_file_range(2) and 
sendfile/tee/splice/vmsplice, so that will have to be glossed over by 
portability code.

Finally, this is a spare time project, something I've mostly been poking 
at while having idle time on a not-Internet-connected laptop. 
Technically its sponsored by Red Hat, since RH pays my salary for all my 
open source work, but this is largely a personal project done for 
personal reasons.  I just hope others find it interesting or useful, as 
it progresses.

	Jeff

