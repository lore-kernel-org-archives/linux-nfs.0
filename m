From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: more info please
Date: 14 May 2003 23:56:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsznlpmbuj.fsf@charged.uio.no>
References: <OF61972254.2A6DD5CA-ON85256D26.006F5DFB-86256D26.006F766B@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Bruce Allan" <bruce.allan@us.ibm.com>,
	  Matt Schillinger <mschilli@vss.fsi.com>,  nfs@lists.sourceforge.net,
	  nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: "Duc Vianney" <dvianney@us.ibm.com>
In-Reply-To: <OF61972254.2A6DD5CA-ON85256D26.006F5DFB-86256D26.006F766B@pok.ibm.com>
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

>>>>> " " == Duc Vianney <dvianney@us.ibm.com> writes:

     > How about NFSv4 statistics ??? ...

NFSv4 is a bit more difficult as there are only 2 RPC calls that are
defined: NULL and COMPOUND.

We're working around this to provide more detailed statistics, but for
the moment we're limited to the following:

  <NULL> <COMPOUND> <READ> <WRITE> <COMMIT> <OPEN> <OPEN_CONFIRM>
  <CLOSE> <SETATTR>

(where <COMPOUND> in the above list means: "all other operations")

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
