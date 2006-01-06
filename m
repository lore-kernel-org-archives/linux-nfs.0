From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS performance tuning
Date: Fri, 06 Jan 2006 12:07:45 -0500
Message-ID: <1136567265.7839.25.camel@lade.trondhjem.org>
References: <43BE9EC3.3090108@totalflood.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Euv4Q-0006cG-6t
	for nfs@lists.sourceforge.net; Fri, 06 Jan 2006 09:08:06 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Euv4O-0002uS-9Y
	for nfs@lists.sourceforge.net; Fri, 06 Jan 2006 09:08:06 -0800
To: Stephen Carville <stephen@totalflood.com>
In-Reply-To: <43BE9EC3.3090108@totalflood.com>
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

On Fri, 2006-01-06 at 08:45 -0800, Stephen Carville wrote:
> I have NFS server running on a Dell 2850:
> 
>    Name: Amazon
>     CPU: 3000 Mhz Xeon  (X2)
> Memory: 2G
>    Swap: 8G
>      OS: Fedora Core 3
>     NFS: Version 1-4
> 
> I export a 150G volume thusly:
> 
> /NFS/tigris_backup
> 10.1.1.0/24(rw,wdelay,nohide,insecure,root_squash,no_subtree_check,anonuid=65534,anongid=65534)
> 
> The client is a Dell 2650 running Oracle 9i
> 
>    Name: Tigris
>     CPU: 3200Mhz Xeon (X2)
> Memory: 8G
>    Swap: 4G
>      OS: Redhat ES 3.2
>     NFS: Version 2/tcp

Why are you using NFSv2? That forces the server to use synchronous
writes (i.e. each write must be committed to disk before the server
replies to the client) and is very inefficient.

If your application is write-intensive, you should always choose NFSv3
or greater.

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
