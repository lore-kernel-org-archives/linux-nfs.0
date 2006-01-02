From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS re-export of non-local mountpoint
Date: Mon, 02 Jan 2006 19:11:20 +0100
Message-ID: <1136225481.18522.40.camel@lade.trondhjem.org>
References: <OF9EFE8519.B9EB421D-ONC12570EA.004FBF22-C12570EA.00519D78@de.ibm.com>
	 <1136224021.18522.22.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EtU9b-0005Rr-OZ
	for nfs@lists.sourceforge.net; Mon, 02 Jan 2006 10:11:31 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EtU9a-0002mn-2G
	for nfs@lists.sourceforge.net; Mon, 02 Jan 2006 10:11:31 -0800
To: Holger Smolinski <smolinski@de.ibm.com>
In-Reply-To: <1136224021.18522.22.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, 2006-01-02 at 18:47 +0100, Trond Myklebust wrote:
> On Mon, 2006-01-02 at 15:51 +0100, Holger Smolinski wrote:
> > Happy New Year,
> > 
> > We are looking for a solution, that will allow us to re-export a non-local 
> > mountpoint (e.g. Samba Share, or NFSmount) through at least NFSv3 to 
> > another system using a Linux NFS Server.
> > Sinde knfsd lacks this functionality and we are not aware of any currently 
> > maintained user space  Linux NFS Server, that has this capability, we are 
> > currently assessing the effort to add this functions to the knfsd. So far 
> > I have understood, that the problem is in the file structure, that has to 
> > carry 2 server file handles for the file and its parent directory, while 
> > the current file structure has only space for inode numbers, that are 
> > shorter than NFS server file handles. Are there any other issues, you see 
> > and we need to take care of?
> 
> Yes: an NFS client doesn't do lookup of files or directories by inode
> number, so the above scheme won't work unless the file happens to be in
> cache.

BTW: why would you want to care about tracking the parent directory? I
know knfsd does this if you set the subtree_check flag, but that is
generally considered a bug.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
