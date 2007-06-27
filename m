From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS PATCH] Fix the issue of writing data over
	NFS	concurrently both on client and Server uncorrectly
Date: Tue, 26 Jun 2007 23:39:52 -0400
Message-ID: <1182915592.12836.74.camel@heimdal.trondhjem.org>
References: <4681DA92.8020303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfsv4@linux-nfs.org" <nfsv4@linux-nfs.org>,
	"nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: shichao <shichao@cn.fujitsu.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3ONq-0002w2-7F
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 20:39:58 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX182ahK1UDItTUtB2WXVa25K665VqMYO+Vw=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3ONq-00011S-QD
	for nfs@lists.sourceforge.net; Tue, 26 Jun 2007 20:40:01 -0700
In-Reply-To: <4681DA92.8020303@cn.fujitsu.com>
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

On Wed, 2007-06-27 at 11:33 +0800, shichao wrote:
> Hi everybody,
> 
> When I write data on file over NFS (mounted aync)  both on client and on Server, 
> sometimes the client seems to miss the server's updated data and commit the stale cache data to the nfs server. This
> leads to a file writed uncorrectly.
> 
> Example on a local dir /local/testdir/foo NFS-exported to the localhost on /nfs/foo:
>  The exportfs option in server is: /nfs/  *(rw,sync,root_no_squash)
> 
> [root@rhel5~]# mount server:/nfs  /local/testdir
> 
>  My test program's main flow is as follows:
>   1) fd = open("/local/testdir/foo", oflags, CHMOD_RW )
>   2) wbuf="testmsg-1-"; write(fd, wbuf, strlen(wbuf))
>   3) On nfs Server: echo "testmsg-2-" >> /nfs/foo    (using rsh)
>   4) sleep(6); lseek(fd, 0L, SEEK_END)
>   5) wbuf="testmsg-3-"; write(fd, wbuf, strlen(wbuf))
>   6) lseek(fd, 0L, 0); read(fd, rbuf, MAX_DATA_SIZE)
> 
>  It is expected that the file data should be "testmsg-1-testmsg-2-testmsg-3",

No. The expectation in this case is precisely what you saw. You should
not be changing the file on the server unless you are using file locking
or some other synchronisation mechanism.

Please read the NFS FAQ on close-to-open cache consistency:
	http://nfs.sourceforge.net/#faq_a8

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
