From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: query
Date: 22 Oct 2003 09:45:47 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy8vdpbz8.fsf@charged.uio.no>
References: <NGBBKDKMALCPDNMIPMPLKENFCAAA.sundar@cdacb.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ACM9v-0000FU-00
	for <nfs@lists.sourceforge.net>; Wed, 22 Oct 2003 09:48:31 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1ACKIF-0005Np-3d
	for nfs@lists.sourceforge.net; Wed, 22 Oct 2003 07:48:59 -0700
To: "Sundareswar Jayakumar" <sundar@cdacb.ernet.in>
In-Reply-To: <NGBBKDKMALCPDNMIPMPLKENFCAAA.sundar@cdacb.ernet.in>
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

>>>>> " " == Sundareswar Jayakumar <sundar@cdacb.ernet.in> writes:

     > Hi,
     > 	I am working on adistributed filesytem on linux.I am using
     > nfs source code as a learning resource.I require a
     > clarification.


     > In many entry points the Big Kernel Lock lock/unlock_kernel is
     > used instead of locking just the private data structures of the
     > filesystem.why is it so?.kindly clarify w.r.t to a smp m/c.

When working on performance, you pursue the largest sources of latency
first...
BKL contention has not yet turned up on the radar screen. There has
therefore not yet been enough incentive to replace it as a mechanism
for serialization.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by OSDN developer relations
Here's your chance to show off your extensive product knowledge
We want to know what you know. Tell us and you have a chance to win $100
http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
