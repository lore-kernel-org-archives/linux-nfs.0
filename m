From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Performance tuning
Date: 10 Jul 2002 23:17:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswus3xoyy.fsf@charged.uio.no>
References: <Pine.LNX.4.33.0207100905100.27879-100000@lewis.et.byu.edu>
	<3D2CA166.CD962038@attbi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dougall <davidd@et.byu.edu>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SOpv-0006Ea-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 14:17:23 -0700
To: Tom McNeal <trmcneal@attbi.com>
In-Reply-To: <3D2CA166.CD962038@attbi.com>
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

>>>>> " " == Tom McNeal <trmcneal@attbi.com> writes:

     > I also corrected the fragmentation part to refer to all
     > kernels.  The main thing to look for is MTU, plus the number of
     > reassambly failures noted as "reasmfails" in /proc/net/snmp,
     > especially when you start using 32K in udp (which is probably
     > not the best idea).

Note that the number of reassembly failures is particularly inflated
if you are using a Linux client due to a bug in the socket layer: if
there is not enough buffer to send off all the fragments, then the
socket will still send off those fragments for which there is enough
space.
On the server side, this means that it will accumulate junk fragments
which never have a chance of being reassembled.

This 'feature' alone suffices to slow down the write speed to ~50% on
my test setup.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Two, two, TWO treats in one.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
