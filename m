From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Solaris 8 - RH 7.1 NFS Bugs
Date: 04 Jun 2002 14:15:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shslm9v2qb5.fsf@charged.uio.no>
References: <017501c20b44$b291b390$66f1a186@OREILLY>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17FDDd-0001kP-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Jun 2002 05:15:21 -0700
To: Patrick O'Reilly <patrick.oreilly@uni.edu>
In-Reply-To: <017501c20b44$b291b390$66f1a186@OREILLY>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Patrick O'Reilly <patrick.oreilly@uni.edu> writes:

     > johnstown kernel: nfs_statfs: statfs error = 13 johnstown
     > kernel: call_verify: server requires stronger authentication.

Linux does not yet support strong (kerberos) authentication on the
server. We're working on that, but an official patch is still pending.

The reason it works for 'root' is that Sun decided that 'automount'
daemons (that are running as root) should still be allowed to mount
these partitions despite not having any kerberos credentials...

Cheers,
  Trond

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
