From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Thu, 13 Nov 2003 15:02:26 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16307.58194.295707.246141@charged.uio.no>
References: <OF2F88E36F.887DAD35-ON85256DDD.00694D03-86256DDD.006C4237@us.ibm.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Whiting <ewhiting@amis.com>,
    Jason Holmes <jholmes@psu.edu>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKNft-0006hc-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Nov 2003 12:02:41 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AKNfs-00061S-Q4
	for nfs@lists.sourceforge.net; Thu, 13 Nov 2003 12:02:40 -0800
To: Duc Vianney <dvianney@us.ibm.com>
In-Reply-To: <OF2F88E36F.887DAD35-ON85256DDD.00694D03-86256DDD.006C4237@us.ibm.com>
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

     > I ran the iozone in the cluster mode to time read and write
     > under NFSv3.  Under a server memory constraint scenario, I saw
     > reads on 2.6.0-test9 about 8X slower than 2.4.22.  For writes,
     > I saw improvement in 2.6.0-test9 irrespective of server memory
     > size.

This is consistent with what I see on my setups.

The increase in write speed you see is due to the fact that we've
managed to lift the restriction we have in 2.4.x that only 256 writes
writes may be cached before have to we do another COMMIT and flush
them to disk.

The slowdown in reads is something I see too. What's more, both I and
others are also seeing slowdowns on local filesystem reads. I
therefore suspect some bug in the new VFS readahead code, but I still
haven't found time to look into this.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
