From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS - Fix for Infinite loop during syncing
Date: Mon, 13 Dec 2004 16:20:09 -0500
Message-ID: <41BE0789.8070001@RedHat.com>
References: <41BDFA46.7070403@RedHat.com> <1102970704.15627.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CdxXx-0000Ov-3Z
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 13:15:57 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CdxXw-0004j8-7s
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 13:15:57 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1102970704.15627.8.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>m=E5 den 13.12.2004 Klokka 15:23 (-0500) skreiv Steve Dickson:
> =20
>
>>It was brought to my attention that following series of events
>>would cause an infinite loop in the 2.4 nfs kernels.
>>
>>1) Mount the fileystem with acregmin=3D1,acregmax=3D1 from two clients.
>>2) On client 1, create a process that continuously writes to a file.
>>3) On client 2, remove that file that is being written
>>4) On client 1, interrupted out of the writing process (which is failin=
g
>>     with ESTALEs) and type sync
>>
>>The sync process loops in wait_on_locked(), when called from
>>sync_inodes_sb(), since the "broken" inode can not be cleared
>>from the locked inode list.
>>   =20
>>
>
>Isn't this pretty much a generic problem of mmapped files? AFAICS, sync
>can loop here no matter what filesystem one is using.
> =20
>
maybe, but these were not mmapped files... here is perl script I used

open $file, "> filetje.$$" or die "Open failed: $!";
while ( 1 ) {
   print $file time(), " The quick brown fox jumps over the lazy dog,=20
1234567890\n"
}

>If you use ordinary writes, then all is well, since the
>nfs_revalidate_inode() in nfs_file_write() should set the NFS_INO_STALE
>flag for you.
> =20
>
Right... nfs_revalidate_inode() does "break" the inode only after a (in=20
this case)
seconded ESTALE  failure .... By setting NFS_INO_STALE in nfs_write_done(=
)
it breaks the inode earlier, which means the nfs_revalidate_inode() is=20
not even
tried.

Now that I think about it... probably makes sense to set NFS_INO_STALE in
nfs_commit_done() as well... From my debugging, it just seems the=20
earlier we
break the inode... the better....

steved.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
