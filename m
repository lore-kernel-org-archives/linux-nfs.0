From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: mmap() and NFS server performance
Date: 14 Dec 2002 12:22:30 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsadj826bt.fsf@charged.uio.no>
References: <3DFA4C9A.50101@geodev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18NANX-0008Nw-00
	for <nfs@lists.sourceforge.net>; Sat, 14 Dec 2002 03:22:43 -0800
To: Matthew Mitchell <matthew@geodev.com>
In-Reply-To: <3DFA4C9A.50101@geodev.com>
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

>>>>> " " == Matthew Mitchell <matthew@geodev.com> writes:

     > values.  These apps were originally written on Solaris with
     > Solaris NFS servers assumed to be the data source; the Sun guys
     > said that mmap would be much faster than read/write and they
     > were correct.  However, now that we have a few Linux NFS
     > servers, we're seeing the opposite.

As long as the clients are still Solaris, then the only difference can
be the network, and the server performance.

Of the 2, the bigger 'generic' troublemaker tends to be the network.
Solaris clients always tend to prefer NFS over TCP since that tends to
be more reliable on poor networks than does UDP. Unfortunately, NFS
over TCP on the server side is a fairly recent addition to Linux: it
only just made it into the stable release 2 weeks ago (when 2.4.20 was
released). To the best of my knowledge, none of the RedHat kernels
support it yet.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
