From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: processes stuck in D state
Date: Tue, 6 May 2003 18:54:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16055.59608.512121.756564@charged.uio.no>
References: <200305061652.13280.fsdeveloper@yahoo.de>
	<200305061742.14032.fsdeveloper@yahoo.de>
	<16055.56630.615496.19679@charged.uio.no>
	<200305061830.25417.fsdeveloper@yahoo.de>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au,
    nfs@lists.sourceforge.net,
    linux kernel mailing list <linux-kernel@vger.kernel.org>,
    Zeev Fisher <Zeev.Fisher@il.marvell.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D5iT-0006AW-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 09:54:58 -0700
To: Michael Buesch <fsdeveloper@yahoo.de>
In-Reply-To: <200305061830.25417.fsdeveloper@yahoo.de>
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

>>>>> " " == Michael Buesch <fsdeveloper@yahoo.de> writes:

    >> kill -9 all the processes.  kill -9 rpciod.

     > kill -9 doesn't work for me to kill the app.

I didn't say kill the app. I said signal it with -9, then signal
rpciod.

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
