From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: File corruption linux 2.4 nfs client to freebsd server
Date: Wed, 19 Nov 2003 12:43:46 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16315.43986.994562.15500@charged.uio.no>
References: <1069235928.1215.79.camel@krypton.medical-insight.com>
	<shs8ymcs72u.fsf@charged.uio.no>
	<1069260099.2348.14.camel@krypton.medical-insight.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMWMs-0003tH-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 09:43:54 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AMWMs-0002co-7j
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 09:43:54 -0800
To: Morten Sylvest Olsen <mso@medical-insight.com>
In-Reply-To: <1069260099.2348.14.camel@krypton.medical-insight.com>
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

>>>>> " " == Morten Sylvest Olsen <mso@medical-insight.com> writes:

     > I can reproduce the problem on the clients using fsx. The error
     > occurs after 25407 fsx operations with an I/O error, with no
     > difference between test file and fsxgood file. (default options
     > to fsx)

Could you show us the output of the last 20 lines or so from the fsx
logfile? As I said, I'd like to know which operation is failing.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
