From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: more info please
Date: Thu, 15 May 2003 00:37:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16066.50502.902796.455991@charged.uio.no>
References: <OF92BB3471.44BC7B8A-ON88256D26.007B43F7-88256D26.007BA631@us.ibm.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    "Duc Vianney" <dvianney@us.ibm.com>,
    Matt Schillinger <mschilli@vss.fsi.com>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19G4t3-0007R7-00
	for <nfs@lists.sourceforge.net>; Wed, 14 May 2003 15:38:13 -0700
To: Bruce Allan <bruce.allan@us.ibm.com>
In-Reply-To: <OF92BB3471.44BC7B8A-ON88256D26.007B43F7-88256D26.007BA631@us.ibm.com>
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

>>>>> " " == Bruce Allan <bruce.allan@us.ibm.com> writes:

     > Hi Trond,

     > Have the newer statistics counters been put in since 2.5.66?
     > On 2.5.66 all I see are 'proc4 <nproc> <#null> <#compound>'.
     > It's good to know more detail is being added; I really need to
     > grab the latest bits.

Grab the latest bk snapshot. The NFS client on 2.5.x wasn't really
very stable prior to Tuesday's snapshot.

But yes: as you can see we are in the process of adding stuff to the
nfs4_procedures[] array. Those 'RPC procedures' will again provide the
more detailed statistics (and hopefully also faster+better NFSv4
performance).

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
