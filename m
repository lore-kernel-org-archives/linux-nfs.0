From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: regarding size limit of local client cache
Date: 11 Mar 2003 19:37:42 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shssmttiwax.fsf@charged.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E07D5538B@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Abhishek Rai" <abbashake007@yahoo.com>,  <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18sodN-0007Mf-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 10:37:53 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D5538B@black.eng.netapp.com>
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

>>>>> " " == Charles Lever <Lever> writes:

     > hi- you didn't tell us how large your client's RAM is, what
     > your mount options are, what other programs are running on the
     > clients, nor how long each client takes to read (attribute
     > cache invalidation might cause each client to purge its cache,
     > for instance).

     > as far as i know there is no 8192 page limit in the NFS client.

Right. The size of the page cache is limited only by the available
free memory.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
