From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] locks: provide a file lease
	method	enabling	cluster-coherent leases
Date: Tue, 05 Jun 2007 19:40:28 -0400
Message-ID: <1181086828.6108.11.camel@heimdal.trondhjem.org>
References: <OFB9D089FA.C0E6BE5A-ON882572F1.007D3720-882572F1.007E299C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-fsdevel@vger.kernel.org,
	Robert Rappaport <robert.rappaport@gmail.com>,
	David Teigland <teigland@redhat.com>, nfs@lists.sourceforge.net
To: Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hvidj-0000MD-7q
	for nfs@lists.sourceforge.net; Tue, 05 Jun 2007 16:40:39 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18nDbassnl4McEQm8FnYH5JFjNh5sCyqtg=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hvidk-0003Sy-SB
	for nfs@lists.sourceforge.net; Tue, 05 Jun 2007 16:40:42 -0700
In-Reply-To: <OFB9D089FA.C0E6BE5A-ON882572F1.007D3720-882572F1.007E299C@us.ibm.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2007-06-05 at 15:56 -0700, Marc Eshel wrote:
> Hi Bruce,
> The file system does need to keep the local state up to date, like it does 
> with posix locks, so it might need to call __setlease(). The why we had it 
> before was that the call to the file system was done from outside of 
> setlease() and the file system was able to call setlease() which is 
> exported. Now that the call to the fs  moved into setlease() the file 
> system can not call it anymore so one possible solution would be to export 
> __setlease().
> Marc.

Please just make a vfs_setlease() which has the ability to call down
into the filesystem and leave the exported setlease() as a generic
method that can continue to be called by the filesystems themselves (and
acts as a fallback for vfs_setlease()). That would be closer to the VFS
naming conventions.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
