From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: SM_UNMON again -> kernel
Date: 14 Jul 2003 10:56:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsptkdij1a.fsf@charged.uio.no>
References: <20030711061615.GA1924@quasar.nro.au.com>
	<shsr84x768e.fsf@charged.uio.no> <87smpbkt55.fsf@ceramic.fifi.org>
	<shs8yr2h2jr.fsf@charged.uio.no> <87k7aml330.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lawrence Ong <lawrence.ong@netregistry.com.au>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19bz86-0001k4-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 01:56:19 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <87k7aml330.fsf@ceramic.fifi.org>
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

>>>>> " " == Philippe Troin <phil@fifi.org> writes:

     > On machine #1: ceramic rpc.statd[30693]: Received erroneous
     > SM_UNMON request from ceramic for 216.27.190.149

     > On machine #2: tantale rpc.statd[18416]: Received erroneous
     > SM_UNMON request from tantale for 216.27.190.148

OK. Hang on... The above looks more like stale entries due to somebody
having permanently switched off a server on which ceramic/tantale were
holding locks.

Could you check on 'ceramic', and 'tantale' if they don't have entries
for 216.27.190.149 and 216.27.190.148 respectively in /var/lib/nfs/sm
or /var/lib/nfs/sm.bak?

Another mistake that can cause the above errors is if the sysman has
made those 2 directories NFS shared between different clients. (Not a
good idea...)

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
