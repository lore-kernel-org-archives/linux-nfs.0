From: Brian Mancuso <bmancuso@akamai.com>
Subject: Re: NFS/UDP slow read, lost fragments
Date: Thu, 25 Sep 2003 17:44:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030925174426.B787@muppet.kendall.corp.akamai.com>
References: <Pine.LNX.4.44.0309251019170.28586-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2dv1-0006IW-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 14:44:59 -0700
Received: from fw01.cmbrmaks.akamai.com ([80.67.64.10] helo=akamai.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2dv0-0000Kb-B6
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 14:44:58 -0700
Received: from akamai.com (vwall2.kendall.corp.akamai.com [172.17.4.34])
	by akamai.com (8.11.7+Sun/8.11.6) with ESMTP id h8PLiR100974
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 17:44:27 -0400 (EDT)
Received: from muppet.kendall.corp.akamai.com (muppet.kendall.corp.akamai.com [172.17.8.20])
	by akamai.com (8.11.7+Sun/8.11.6) with ESMTP id h8PLiQK00970
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 17:44:26 -0400 (EDT)
Received: (from bmancuso@localhost)
	by muppet.kendall.corp.akamai.com (8.11.6/8.9.3) id h8PLiQS15513
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 17:44:26 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0309251019170.28586-100000@localhost.localdomain>; from rmillner@transmeta.com on Thu, Sep 25, 2003 at 10:59:43AM -0700
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

On Thu, Sep 25, 2003 at 10:59:43AM -0700, Robert L. Millner wrote:
: Hello,
: 
: The problem I am seeing is similar to what was posted by Larry Sendlosky
: on Jun 27, "2.4.20-pre3 -> 2.4.21 : nfs client read performance broken"
: though I have not done as through a drill-down into the nature of the
: problem.
: 
: Somewhere between 2.4.19 and 2.4.20, NFS/UDP read performance began to
: suck because of a large number of request retransmits.  From tcpdump, the
: retransmits are for read transactions which return data in a reasonable
: time frame but are missing one or more fragments of the return packet.

This is because code that exponentially backs off RTO for UDP RPC was
backported from the 2.[56] series in 2.4.20, and this code is
completely broken. Trond has a patch in his patchset for 2.6 that
significantly fixes these problems, however this patch still has one
problem that can result in a large number of unnecessary retransmits
for RPC sessions that have low variance in RTT: RTO is calculated to
be the filtered round trip time plus a small constant times the mean
deviation of round trip times. However, because the RTT calculation
code implements Karn's algorithm (from TCP: RTT calculation isn't done
for responses to RPC requests that have been retransmitted), RTT is
never allowed to increase, for were a response to take longer than
measured RTT plus the (assumed small) deviation, the packet will be
retransmitted and a calculatation that will increase measured RTT
won't be done. Thus if a server's real RTT were to increase over time,
initial RTO values would never grow (for measured RTT would never grow
beyond the minimum ever measured), and RPC requests will frequently be
retransmitted at least once. This can be easily remedied however by
TCP's technique of inheriting backoff of RTO from previous
transactions: create a new variable somewhere in the clnt structure
called, say, cl_backoff; Each time an RPC transaction completes, store
the number of retransmits for that transaction (req->rq_nresend) in
cl_backoff; calculate RTO to be rpc_calc_rto() left shifted by the
number of retransmits for this transaction (initially 0) plus
clnt->cl_backoff (the number of retransmits for the last completed
transaction).

The backported code mentioned above will also result in significantly
more EIO events for users with soft UDP mounts. Users seeing lots of
EIO's should see them diminish after these problems are fixed.

: Is this a known problem?  Is there a patch already out there or in the
: works that fixes this?  What other data would help drill into this
: problem?

I will post a patch tomorrow for 2.4.20.

Brian Mancuso


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
