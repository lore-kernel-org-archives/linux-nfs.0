From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs: task 51504 can't get a request slot
Date: 16 May 2002 12:28:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs661ogzdr.fsf@charged.uio.no>
References: <Pine.LNX.4.31.0205151619170.27374-100000@snowball.fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178IVG-0002Wc-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 03:28:58 -0700
To: Steven Timm <timm@fnal.gov>
In-Reply-To: <Pine.LNX.4.31.0205151619170.27374-100000@snowball.fnal.gov>
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

>>>>> " " == Steven Timm <timm@fnal.gov> writes:

     > REcently I have seen a number of nodes running Redhat 7.1 plus
     > 2.4.9-31 kernel give the above message a number of times.  Any
     > process which is trying to access nfs at the moment hangs and
     > can't be killed except by shutting down the network altogether,
     > plus the load spikes by one for each one of these processes.

Usually means there is a networking problem (more often than not a
network driver/card bug). See the FAQ on 
  http://nfs.sourceforge.net

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
