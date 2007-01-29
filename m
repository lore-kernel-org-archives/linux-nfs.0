From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS client problems with Tru64 NFS server
Date: Mon, 29 Jan 2007 18:59:38 -0500
Message-ID: <1170115178.6688.24.camel@lade.trondhjem.org>
References: <63f285650701291342w396ae046t1d38de91ec4345fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Dan Goetzman <dan.goetzman@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBgQ0-0006gv-QY
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 16:00:13 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/vrcE5OzjtYVBSSUY6y3z+54ezCa2SlM4=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBgQ0-0007qv-4F
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 16:00:14 -0800
In-Reply-To: <63f285650701291342w396ae046t1d38de91ec4345fc@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-01-29 at 15:42 -0600, Dan Goetzman wrote:
> Using 2.6.19-1.2895.fc6 I have problems with Tru64 NFS file servers
> using recent Linux NFS clients. I get the error "Not a directory" when
> I try to cd to various sub dirs on the NFS filesystem. The problem, I
> think,  appears to be that the NFS client code detects the directory
> is on a different filesystem (it is not). Or at least that is what it
> appears like to me. The problem remains for a given mount once a sub
> directory has this problem. A umount/mount will clear the problem but
> then I will see in on another sub directory. 
> 
> I think the Linux NFS client might not be handling the Tru64 FSID's
> correctly?

...or Tru64 is possibly not handling FSIDs correctly :-)?

> The output of /proc/fs/nfsfs/volumes for the remote NFS filesystem
> appears like;
> 
> NV SERVER   PORT DEV     FSID
> v3 ac13cc8d  801 0:18    6bb2b101:0       
> v3 ac13110f  801 0:36    ffffffffcc98e21e
> 
>  Note the second V3 mount, the FSID returned by the Tru64 server is
> not displayed with the fsid major and fsid minor format. I checked
> with a network trace and this "ffffffffcc98e211e" is in fact the
> correct FSID returned by the Tru64 NFS server (using ADVFS
> filesystems). This problem only appears on NFSV3, not NFSV2 and seems
> to be only with recent Linux kernels (seen here in Fedora Core 6 and I
> have seen the same with RHAS 5). 

The only requirement that we have for fsids is that they remain unique
and consistent for the entire filesystem. If the fsid changes as the
client enters a new subdirectory, then we will create a submount for
that subdirectory. The reason why we have to do this is that the fileid
is not guaranteed to be unique across different fsids (this is true also
of NFSv2 and NFSv3).

Note that we do allow the server to change the fsid, as long as it is
done for the whole filesystem. If we detect that the fsid has changed
for the parent directory as well as for the subdirectory, then we should
normally simply update our cached value for the fsid for this filesystem
instead of creating a submount.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
