From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS Hangs on heavy I/O
Date: Thu, 28 Jun 2007 11:30:36 -0400
Message-ID: <1183044636.6163.42.camel@heimdal.trondhjem.org>
References: <loom.20070628T164810-117@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Rajat <sharma.rajat@hcl.in>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3vxI-0004fA-4C
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 08:30:49 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+Q7sYEwliVB4mXexcpgsBNi8S1mqhO5bw=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3vxJ-0003Xg-W2
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 08:30:51 -0700
In-Reply-To: <loom.20070628T164810-117@post.gmane.org>
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

On Thu, 2007-06-28 at 15:01 +0000, Rajat wrote:
> Hi list,
> 
> I am facing a NFS hang problem when I perform a very heavy I/O on a localhost 
> mount.
> The situation is:
> $>mount -t nfs localhost:/home/RHL /mnt/nfs
> 
> where /home/RHL is a Ext3 Partition (/dev/sda5). Mount paramter was 'hard' by 
> default
> 
> When I perform a heavy I/O on nfs mount
> $> createfile /mnt/nfs/huge_file 512 1048576
> 
> Where createfile would try to write 512 blocks of 1048576 bytes each (each 
> system call of 1048576, 512 times = 512MB file).
> 
> While the file is being created, I tried to ls in the /mnt/nfs directory - and 
> it hanged (after creating about 75MB file). Logging from other terminals was 
> not working as well.
> In my dmesg I found message saying:
> 
> "nfs: server localhost not responding, still trying"

Please use a TCP mount, with a ditto appropriate value for timeo
(preferably just the default of timeo=600).

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
