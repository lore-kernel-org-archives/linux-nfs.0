From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS/UDP slow read, lost fragments
Date: Tue, 14 Oct 2003 10:52:24 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16268.3496.615917.119237@charged.uio.no>
References: <Pine.LNX.4.44.0309251019170.28586-100000@localhost.localdomain>
	<20030925174426.B787@muppet.kendall.corp.akamai.com>
	<shs1xu430p2.fsf@charged.uio.no>
	<20030926170759.H787@muppet.kendall.corp.akamai.com>
	<3F8B4F7B.4010907@RedHat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Mancuso <bmancuso@akamai.com>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9QXL-0001US-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 07:52:35 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9QXK-0003xL-00
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 07:52:34 -0700
To: Steve Dickson <SteveD@RedHat.com>
In-Reply-To: <3F8B4F7B.4010907@RedHat.com>
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

>>>>> " " == Steve Dickson <SteveD@RedHat.com> writes:

     > As you can see the patches does help a little bit but but not
     > as much as I would expect.... Maybe it was the type of testes
     > ran or maybe I didn't run the tests long enough (each test ran
     > for about ~2mins) or maybe my expectations are too high... But
     > it just doesn't seem that these patches really help that much
     > in bringing down the retransmissions...

Thanks for putting numbers to this Steve!

Could you try using the slight variation in

 http://www.fys.uio.no/~trondmy/src/2.4.23-pre7/linux-2.4.23-03-fix_retrans.dif

As you can see, that has a slight change to rpc_set_timeo(): if it
sees that several retransmissions have occurred for a given request,
then it keeps the value of rtt->ntimeouts high for a couple of extra
iterations in order to allow the new value of the timeout to
converge.
The reason for doing this is that if the round trip time changes
suddenly, then it will takes ~ 8 measurements before you converge on
the new value (due to the weighting done in the algorithm).

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
