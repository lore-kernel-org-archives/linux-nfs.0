From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Disabling Symbolic Link Content Caching in NFS Client
Date: 03 Jun 2003 18:08:35 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsbrxfp2ik.fsf@charged.uio.no>
References: <CFCD2C778CF1D611B5B400065B04D5C84A736F@KENTON>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Vivek Goyal' <vivek.goyal@wipro.com>,  trond.myklebust@fys.uio.no,
	  Ion Badulescu <ionut@badula.org>,  viro@math.psu.edu,
	  davem@redhat.com,  ezk@cs.sunysb.edu,  indou.takao@jp.fujitsu.com,
	  nfs@lists.sourceforge.net,  linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19NELN-0006GX-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Jun 2003 09:09:01 -0700
To: Edward Hibbert <EH@dataconnection.com>
In-Reply-To: <CFCD2C778CF1D611B5B400065B04D5C84A736F@KENTON>
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

>>>>> " " == Edward Hibbert <EH@dataconnection.com> writes:

     > Our application consists of a number of machines collaborating
     > on a shared database over NFS.  We therefore require the
     > ability to force data to be sync'd from the client to the
     > backend - and at the moment we do this by disabling caching
     > completely, via the noac option and acquiring and releasing
     > non-exclusive locks round io calls.

What does this have to do with symlinks?

...and why can't you use DIRECTIO? The above sort of application is
exactly what it is being introduced for.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: eBay
Get office equipment for less on eBay!
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
