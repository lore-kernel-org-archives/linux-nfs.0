From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: processes stuck in D state
Date: 06 May 2003 17:20:35 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsel3c85ks.fsf@charged.uio.no>
References: <200305061652.13280.fsdeveloper@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D4FK-0006Yx-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 08:20:46 -0700
To: Michael Buesch <fsdeveloper@yahoo.de>
In-Reply-To: <200305061652.13280.fsdeveloper@yahoo.de>
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

     > Hi!  Please take a look at this problem:

     > [linux-kernel-mailing-list thread]
     > http://marc.theaimsgroup.com/?t=98639966100003&r=1&w=2

If I can hazard a guess: someone is firewalling the lockd port and/or
the statd port.

Either mount using the 'nolock' option, or fix the firewall (see the
HOWTO and/or FAQ).

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
