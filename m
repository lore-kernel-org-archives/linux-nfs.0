From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS server not responding
Date: 04 Dec 2003 13:39:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr7zk5sw4.fsf@guts.uio.no>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>
	<shsptfch1om.fsf@charged.uio.no> <3FCF70D9.1010808@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARyOS-0001TR-Qz
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 10:40:04 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ARyOS-0006hk-38
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 10:40:04 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3FCF70D9.1010808@RedHat.com>
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

>>>>> " " == Steve Dickson <SteveD@redhat.com> writes:

     >     linux-2.4.20-nfs-ia64-EIO.patch - increase RPC_RTO_MIN to
     >     HZ/30

Err.. That's a decrease...

You are setting the minimum timeout value at 1/30th of a second
instead of 1/10th of a second.
(FYI: HZ is the frequency of the timer interrupt. It tells you how many
jiffies make up 1 second.)


This might indeed explain why people are seeing an increase in resends
and 'server not responding' messages.

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
