From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Bug: 2.5.47 NFS reports giant filename in readdir
Date: 18 Nov 2002 21:47:04 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shslm3qd2rb.fsf@charged.uio.no>
References: <20021118192119.12935.qmail@linuxmail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18DsnZ-0001sB-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 12:47:14 -0800
To: "Felipe Alfaro Solana" <felipe_alfaro@linuxmail.org>
In-Reply-To: <20021118192119.12935.qmail@linuxmail.org>
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

>>>>> " " == Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> writes:

     > The last command produces an empty listing, even when the
     > directory contains 16694 files on it. When I do a "dmesg" on my
     > 2.4.20-rc1 machine, I see the following errors:

Sigh. Yep. It's a known issue with 2.4.20-rc1 and rc2. Fix is

http://www.fys.uio.no/~trondmy/src/2.4.20-pre9/linux-2.4.20-00-fix_overflow.dif


Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
