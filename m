From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Error mounting nfs clients
Date: 27 Nov 2002 21:46:37 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsbs4aeo5u.fsf@charged.uio.no>
References: <E2A41F3CFE5FD411ABC900508BAE0BEE02CAF4F2@power.coe.montana.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	  "'Valhalla-list@redhat.com'" <Valhalla-list@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18H951-00071f-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Nov 2002 12:46:43 -0800
To: "Albers, Lucas" <luke@coe.montana.edu>
In-Reply-To: <E2A41F3CFE5FD411ABC900508BAE0BEE02CAF4F2@power.coe.montana.edu>
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

>>>>> " " == Lucas Albers <Albers> writes:

     > After researching the issue.  It appears that the error is
     > related to the defined value:
     > 	NFS_FHSIZE
     > in the code listed below in this file:
     > /usr/src/linux-2.4.18-5/fs/nfsd/nfsctl.c

     > /*-----------------------------------------------------*/
     >         if (err == 0) {
     >                 if (fh.fh_size > NFS_FHSIZE)
     >                         err = -EINVAL;
     > /*-----------------------------------------------------*/

     > It appears that raising the value:

     > #define NFS_FHSIZE 32

     > Defined in /usr/include/linux/nfs.h Would fix the problem.

If you do that, you will no longer be running NFSv2. Under NFSv2, file
handle sizes are 32 bytes long, no more, no less...

If the filesystem you are using needs to generate filehandles that are
greater that 32 bytes long, then you will probably only be able to use
it with NFSv3

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
