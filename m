From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Mon, 03 May 2004 17:27:28 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083619647.3896.126.camel@lade.trondhjem.org>
References: <40892507.2030004@RedHat.com>  <4093CCB6.1040500@RedHat.com>
	 <1083439518.3687.19.camel@lade.trondhjem.org> <4094397C.3030303@RedHat.com>
	 <1083457337.3687.60.camel@lade.trondhjem.org> <409468B2.40200@RedHat.com>
	 <1083468517.3687.70.camel@lade.trondhjem.org> <4096A292.8050109@RedHat.com>
	 <1083615338.3896.92.camel@lade.trondhjem.org> <4096ACA0.9050507@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKkym-0006BA-Vt
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 14:28:00 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BKkyH-0003oZ-EZ
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 14:27:29 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4096ACA0.9050507@RedHat.com>
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

On Mon, 2004-05-03 at 16:33, Steve Dickson wrote:
> >
> Here are two if the runs I've seen... The first one is without the 
> patch, the second
> one is with the patch...
> 
> client rpc stats:
> calls      retrans    authrefrsh
> 30073      7          0
> Client nfs v3:
> null       getattr    setattr    lookup     access     readlink
> 0       0% 2280    7% 1199    3% 2595    8% 1173    3% 250     0%
> read       write      create     mkdir      symlink    mknod
> 3954   13% 11892  39% 893     2% 175     0% 250     0% 0       0%
> remove     rmdir      rename     link       readdir    readdirplus
> 1391    4% 175     0% 376     1% 250     0% 0       0% 1119    3%
> fsstat     fsinfo     pathconf   commit
> 1500    4% 1       0% 0       0% 600     1%
> 
> 
> Client rpc stats:
> calls      retrans    authrefrsh
> 34134      22         0
> Client nfs v3:
> null       getattr    setattr    lookup     access     readlink
> 0       0% 2124    6% 1199    3% 2979    8% 1174    3% 250     0%
> read       write      create     mkdir      symlink    mknod     
> 3954   11% 15752  46% 893     2% 175     0% 250     0% 0       0%
> remove     rmdir      rename     link       readdir    readdirplus
> 1391    4% 175     0% 380     1% 250     0% 0       0% 1119    3%
> fsstat     fsinfo     pathconf   commit
> 1500    4% 1       0% 0       0% 568     1%
> 
> The lookups and writes seem to sky rocketing....

Interesting... You've got a few more renames too.

I assume those are just extra sillyrenames() if this was a standard
Connectathon test workload. OK... So the extra sillyrename() might
explain why you get more lookups() (assuming at least one of the
sillyrenames is on one of those large directories that Cthon creates).
The extra writes probably account for the sillyrenames() because they
change the timing of close()...

So the big question is: *why do you get all those extra writes*?

Hmm... Just wanting to check: the above results were indeed made with
only the patch I sent you applied?
There weren't any extra changes to nfs_refresh_inode() that might cause
the actual page cache invalidation to depend on the inode ctime (as
opposed to just the lookup cache)?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
