From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS/UDP slow read, lost fragments
Date: Tue, 14 Oct 2003 23:27:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16268.48786.711440.214276@charged.uio.no>
References: <Pine.LNX.4.44.0309251019170.28586-100000@localhost.localdomain>
	<20030925174426.B787@muppet.kendall.corp.akamai.com>
	<shs1xu430p2.fsf@charged.uio.no>
	<20030926170759.H787@muppet.kendall.corp.akamai.com>
	<3F8B4F7B.4010907@RedHat.com>
	<16268.3496.615917.119237@charged.uio.no>
	<3F8CBC39.3020002@RedHat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9cJm-0004Ph-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 20:27:22 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9cJl-0007qN-EX
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 20:27:21 -0700
To: Steve Dickson <SteveD@RedHat.com>
In-Reply-To: <3F8CBC39.3020002@RedHat.com>
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

     > Trond Myklebust wrote:

    >> Could you try using the slight variation in
    >>
    >>
     > It didn't seem to help much... here the numbers...

Oh well, a 1.5% retransmission rate is in any case not a major
problem. It is more than we should see given that we are setting a
timeout of > 4 standard deviations, but it is consistent with what I
see in my own tests...

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
