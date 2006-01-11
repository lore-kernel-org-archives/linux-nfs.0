From: Al Active <LLLActive@GMX.Net>
Subject: Re: Searching NFS Archives
Date: Wed, 11 Jan 2006 14:21:57 +0100
Message-ID: <1136985717.6819.139.camel@L10-WS-AWS1.AWS>
References: <200601111140.30115.vincent.roqueta@ext.bull.net>
	 <1136976671.6819.85.camel@L10-WS-AWS1.AWS>
	 <200601111230.45581.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EwfvT-0000se-TT
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 05:22:07 -0800
Received: from mail.gmx.net ([213.165.64.21])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EwfvR-00066n-6s
	for nfs@lists.sourceforge.net; Wed, 11 Jan 2006 05:22:07 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <200601111230.45581.vincent.roqueta@ext.bull.net>
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

On Wed, 2006-01-11 at 12:30 +0100, Vincent Roqueta wrote:

> 
> Can you try to test using the v4 version (exports your /export directory with 
> the fsid=0 option and mount -t nfs4 nfs-server:/ /mount/point/ )
> 
> Vincent
> 

On the NFS-Server, I did the /etc/exports with fsid=0 option 

:: exports ::

/Data/NFS-Server/ *(rw,fsid=0,root_squash,sync)
...

and restarted "rcnfsserver restart" and "exportfs -r"; but I do not know
if the fsid=0 is active or not. How can I determine that? nfsstat only
delivers v2 & v3 stats for server and client though.

Adding the option nfs4 in the fstab of the NFS-Client in place of the
existing 'nfs' on the client initially causes an error with 'mount -a' =
"can't read superblock". With the 'nfs' option it still worked. 

:: fstab ::
...
192.168.0.124:/Data/NFS-Server	/Export/NFS-Server nfs4	defaults 0 0
...

I tried again after a new start of the system with the nfs4 option and
now it seems to mount normally. I'm not sure if it is nfs4, because the
'mount' command only shows nfs and nfsstat shows nfs2 & nfs3 as file
system. 

With nfsstat -c I only see nfs client v2 & v3. How do I get client v4 up
and running?

:-)
Al



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
