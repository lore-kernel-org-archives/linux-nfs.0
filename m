From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Tue, 16 Nov 2004 18:18:42 +0100
Message-ID: <419A3672.8040305@int-evry.fr>
References: <482A3FA0050D21419C269D13989C61130435EB6A@lavender-fe.eng.netapp.com> <1100622780.10975.51.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Charles Lever <Charles.Lever@netapp.com>,
	Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CU6yv-000381-9h
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 09:19:05 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CU6yu-0003zg-Me
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 09:19:05 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1100622780.10975.51.camel@lade.trondhjem.org>
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

>ty den 16.11.2004 Klokka 08:15 (-0800) skreiv Lever, Charles:
>  
>
>>is the effect of the "sync" export option limited to NFSv3 COMMIT, or is
>>it limited to both NFSv3 COMMIT and NFSv3 FILE_SYNC/DATA_SYNC WRITE?
>>
>>what are the effects on NFSv4 writes and commits?
>>    
>>
>
>No! It is clearly not just limited to writes and commits.
>
>Look at the code in fs/nfs/vfs.c: there are EX_ISSYNC() exceptions that
>wrap calls to nfsd_sync_dir() in nfsd*_create(), nfsd_symlink(),
>nfsd_link(), nfsd_rename(), and nfsd_unlink().
>
>Cheers,
>  Trond
>
>  
>
By the way, I noticed on a performance factor of 30 (!) from an sync to 
async nfs v3 export FS :

sync export:

$time tar xvfz linux-2.6.8.tar.gz
real    64m18.618s
user    0m5.742s
sys     0m15.658s

async export:

$time tar xvfz linux-2.6.8.tar.gz
real    2m0.552s
user    0m5.838s
sys     0m15.678s


Is it really dangerous to use async ? why recent OS uses sync by default 
(My client is a Fedora Core 2 (kernel 2.6)  and server an RedHat 
Entreprise server 3 (kernel 2.4))

thanks.


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
