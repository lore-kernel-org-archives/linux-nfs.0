From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
Date: Thu, 4 Sep 2003 16:08:59 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16215.39899.241145.441186@charged.uio.no>
References: <shsekzcjnbt.fsf@charged.uio.no>
	<Pine.LNX.4.44.0309041128520.5868-100000@fubar.phlinux.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19v0Pt-0008Fb-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Sep 2003 13:09:17 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19v0Ps-0005EU-G7
	for nfs@lists.sourceforge.net; Thu, 04 Sep 2003 13:09:16 -0700
To: Matt C <wago@phlinux.com>
In-Reply-To: <Pine.LNX.4.44.0309041128520.5868-100000@fubar.phlinux.com>
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

>>>>> " " == Matt C <Matt> writes:

     > Hi Trond- I applied this patch to one of my clients, and it
     > seems to have helped. However, I'm still getting a lot of the:

     > server x not responding, still trying server x OK server x not
     > responding, still trying server x OK

     > when the server is heavily loaded. what values would be
     > reasonable for the
     > #defines below in order to increase this timeout significantly? 
     > #I tried
     > changing RPC_RTO_MIN to (HZ/5) and RPC_RTO_INIT to (HZ/2), but
     > that didn't seem to make a big difference. I'm having a hard
     > time understanding the rpc_update_rtt() function.

The rpc_update_rtt() function is pretty standard. It is documented in
a paper by Van Jacobson from 1998. See:
    http://www-nrg.ee.lbl.gov/nrg-papers.html

To summarize: that function is just measuring the round-trip-time
(rtt) for each request, and then using that to build up an estimate
for the old 'timeo' mount option. The estimate takes into account
random fluctuations by also maintaining an estimate of the error on
the rtt. RPC_RTO_MIN is just a minimum value for that estimated error.

Note: If it is getting the estimate wrong, then that indicates that a
graph of your round trip time will show large 'spikes' at certain
moments. I would suggest that you ought to look into why this is the
case.
Are you, for instance, running with enough NFS server threads? Are the
switches/routers between you and the server up to the task, or are
they perhaps dropping large numbers of packets?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
