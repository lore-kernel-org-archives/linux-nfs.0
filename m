From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 12:16:11 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4089414B.8090102@RedHat.com>
References: <482A3FA0050D21419C269D13989C61130435DF4D@lavender-fe.eng.netapp.com> <1082732429.2617.35.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Charles Lever <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH3LM-0006kj-Bk
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 09:16:00 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BH3LL-0005Ww-Uh
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 09:16:00 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1082732429.2617.35.camel@lade.trondhjem.org>
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

>On Fri, 2004-04-23 at 10:48, Lever, Charles wrote:
>  
>
>>there appears to be a real problem when restoring from a backup,
>>or using rsync.  the file size and the mtime stay precisely the
>>same, but the file handle changes.  i'm not sure anything can be
>>done about this in NFSv2/3?
>>    
>>
>
>The only way to distinguish the two is to replace the use of the mtime
>with the ctime in nfs_check_verifier() and friends.
>  
>
Again.. this was the first place I looked... And I just can't figure how
to use NFS_CACHE_CTIME() in any meaningful calculation...

>Under ordinary circumstances, the mtime and ctime should be more or less
>identical, 
>
In this particular case they aren't because the server explicitly
maintains the "old" mtime and since mtime does not change we'll never
get the new ctime...

>so I'm not sure why Steve was seeing extra revalidations when
>he was running the Connectathon suite. Were you perhaps changing the
>algorithm in nfs_refresh_inode() instead, Steve?
>  
>
A very keen observation... Yes, when I introduced ctime into the valid or
not valid calculation, the getattrs (i.e revalidations) but even more
surprising (at least to me) was the number of reads sky rocked when
I ran the cthon tests...

SteveD.


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
