From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Determining version, current block size, setting default
Date: 20 Mar 2003 10:47:30 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsu1dymkst.fsf@charged.uio.no>
References: <3E791684.4070403@kealia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18vweI-0008Bp-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Mar 2003 01:47:46 -0800
To: Ed Swierk <eswierk@kealia.com>
In-Reply-To: <3E791684.4070403@kealia.com>
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

>>>>> " " == Ed Swierk <eswierk@kealia.com> writes:

     > Hello, I'm running Linux 2.4.18 kernels on my NFS server and
     > clients, and am trying to debug what seems to be an incorrectly
     > configured block size.


     > Are there ways to:

     > - determine what version of the NFS protocol is being used by an
     >   existing NFS mount?


cat /proc/mounts

     > - determine what block size is being used for an existing NFS
     >   mount?

cat /proc/mounts

     > - set the default block size on the NFS (v3?) server, so I don't have
     >   to specify rsize and wsize on every client?

No

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: Tablet PC.  
Does your code think in ink? You could win a Tablet PC. 
Get a free Tablet PC hat just for playing. What are you waiting for? 
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
