From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: NFS problems with Linux-2.4
Date: 21 May 2003 15:48:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsu1boz9zx.fsf@charged.uio.no>
References: <20030513145023.GA10383@ncsu.edu>
	<16065.3323.449992.207039@charged.uio.no>
	<mailman.1053012601.1068.linux-kernel2news@redhat.com>
	<3ECB6570.2040303@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IXDN-00066r-00
	for <nfs@lists.sourceforge.net>; Wed, 21 May 2003 10:17:21 -0700
To: Steve Dickson <SteveD@RedHat.com>
In-Reply-To: <3ECB6570.2040303@RedHat.com>
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

>>>>> " " == Steve Dickson <SteveD@RedHat.com> writes:

     > Hello, While its true that this program, p1.c with the rename,
     > does not really check cto cache consistency it still should
     > work (IMHO)..

     > After some investigation it turns out that the timestamps that
     > is used in handling negative lookups was not being updated as
     > precisely as it could be... And since this timestamps is also
     > used with other caches (namely the readdir cache), ISTM, that
     > keeping in sync (as much as possible) with the server is a good
     > thing...

Steve,
  That patch is wrong. I've already told you why...

Cheers,
   Trond


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
