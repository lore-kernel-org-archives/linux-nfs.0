From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: A Question about the 2.4.21 Pathconf patch
Date: Wed, 30 Apr 2003 00:47:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16047.285.921874.178993@charged.uio.no>
References: <3EAE956E.9080205@RedHat.com>
	<shs4r4h5l52.fsf@charged.uio.no>
	<3EAEC774.20402@RedHat.com>
	<shssms1ozz6.fsf@charged.uio.no>
	<3EAEEC0D.6040006@RedHat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AdtO-0005kT-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 15:48:06 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3EAEEC0D.6040006@RedHat.com>
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

>>>>> " " == Steve Dickson <SteveD@redhat.com> writes:

     > rpc_call(NFSPROC_FSINFO) which would fill the nfs_fsinfo
     > structure with the values from the server. Of course these
     > values would have to be check for sanity... I just seems to me
     > that would be good information to to have on hand...

It does the RPC call at mount time instead, then caches the results.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
