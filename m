From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Mon, 03 May 2004 16:33:36 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4096ACA0.9050507@RedHat.com>
References: <40892507.2030004@RedHat.com>  <4093CCB6.1040500@RedHat.com>	 <1083439518.3687.19.camel@lade.trondhjem.org> <4094397C.3030303@RedHat.com>	 <1083457337.3687.60.camel@lade.trondhjem.org> <409468B2.40200@RedHat.com>	 <1083468517.3687.70.camel@lade.trondhjem.org> <4096A292.8050109@RedHat.com> <1083615338.3896.92.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKk8C-00079a-LV
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 13:33:40 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BKk8C-0002lc-8e
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 13:33:40 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1083615338.3896.92.camel@lade.trondhjem.org>
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

>On Mon, 2004-05-03 at 15:50, Steve Dickson wrote:
>
>  
>
>>So I would like to propose a less intrusive patch what will simply zap
>>the directories caches when nfs_revalidate() sees an ESTALE.
>>
>>This patch does not effect traffic and only the first dir entry is 
>>failed with ESTALE
>>and finally subsequent ls will not fail with ESTALEs....
>>
>>Comments?
>>    
>>
>
>That one looks fine (although it will not apply to 2.6.x).
>  
>
Its a 2.4 patch...

>I'm still curious to find out which operations are changing ctime on the
>parent directory without changing mtime, though.
>  
>
Here are two if the runs I've seen... The first one is without the 
patch, the second
one is with the patch...

client rpc stats:
calls      retrans    authrefrsh
30073      7          0
Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 2280    7% 1199    3% 2595    8% 1173    3% 250     0%
read       write      create     mkdir      symlink    mknod
3954   13% 11892  39% 893     2% 175     0% 250     0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
1391    4% 175     0% 376     1% 250     0% 0       0% 1119    3%
fsstat     fsinfo     pathconf   commit
1500    4% 1       0% 0       0% 600     1%


Client rpc stats:
calls      retrans    authrefrsh
34134      22         0
Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 2124    6% 1199    3% 2979    8% 1174    3% 250     0%
read       write      create     mkdir      symlink    mknod     
3954   11% 15752  46% 893     2% 175     0% 250     0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
1391    4% 175     0% 380     1% 250     0% 0       0% 1119    3%
fsstat     fsinfo     pathconf   commit
1500    4% 1       0% 0       0% 568     1%

The lookups and writes seem to sky rocketing.... and I've seen other
runs (with using both mtime and ctimes) where the lookups, getattrs
and reads sky rocket

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
