From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS configuration question
Date: 07 May 2003 02:36:30 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsd6iv8uep.fsf@charged.uio.no>
References: <PGEKLHJLLGLFPCINFLBLOEIADJAA.tpickard@crossref.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DCvD-0000z6-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 17:36:36 -0700
To: Tim Pickard <tpickard@crossref.org>
In-Reply-To: <PGEKLHJLLGLFPCINFLBLOEIADJAA.tpickard@crossref.org>
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


     > What am I missing?

The basic fact that NFS was never designed with data cache consistency
in mind. The only way to ensure that processes on different machines
consistently see the same data is to use file locking in order to
synchronize their caches.

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
