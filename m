From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Smooth out NFS client writeback
Date: Thu, 02 Jun 2005 00:38:30 -0400
Message-ID: <1117687110.10822.114.camel@lade.trondhjem.org>
References: <20050602032609.47381.qmail@web30715.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdhTp-0004Da-NN
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 21:38:53 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DdhTn-0003nr-Pi
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 21:38:53 -0700
To: Shantanu Goel <sgoel01@yahoo.com>
In-Reply-To: <20050602032609.47381.qmail@web30715.mail.mud.yahoo.com>
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

on den 01.06.2005 Klokka 20:26 (-0700) skreiv Shantanu Goel:
> Here are some numbers with iozone (avg of 3 runs). 
> The command was run as: iozone -i0 -r4k -s64m -c -t4
> I manually booted the client machine with mem=256M.

What happens when you increase the file size to significantly beyond the
memory size on a slow network. That is the interesting case.
Try, for instance, booting with mem=32m and iozone -s 

> I also ran iozone in mmap mode with same options as
> above but specifying -B as well.  The machine hung
> with the stock client so could not complete the test. 
> Here are the numbers with the patched client.

Where was the machine hanging?

Cheers,
  Trond

BTW: how did you determine the values for NFS_WRITE_CLUSTER and
NFS_COMMIT_CLUSTER. they appear to be completely arbitrary AFAICS.

Also, have you compared to the latest NFS_ALL kernels? They contain a
bunch of extra latency fixes that came from Ingo's RT work.

Finally, please explain _why_ have you removed the FLUSH_STABLE from
nfs_writepage()? The reason for it in the existing code is to avoid the
extra COMMIT call in situations where we know we are already very low on
memory. I don't see anything new in your patches that avoids these low
memory situations.



-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
