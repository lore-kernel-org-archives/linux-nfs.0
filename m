From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lockd recovery not working on RH with 2.6 kernel
Date: Fri, 19 Nov 2004 16:40:14 -0500
Message-ID: <419E683E.9000103@RedHat.com>
References: <OF573E8465.7E3D5CC0-ON88256F49.0064BB5C-88256F49.00698B56@us.ibm.com>	 <419CD343.4000600@RedHat.com> <1100882099.11209.8.camel@lade.trondhjem.org>	 <419E3252.3040602@RedHat.com> <1100895853.11209.35.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1100895853.11209.35.camel@lade.trondhjem.org>
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

>See
>  http://sourceforge.net/mailarchive/message.php?msg_id=9712677
>  
>
This seems a bit more complicated that was need to recover locks...
Although the nlmsvc_dispatch routine is very similar to the one
I posted....

>Just out of curiosity, though... Does this mean that knfsd is now
>sometimes returning NFS3ERR_JUKEBOX to NFSv2 clients?
>  
>
No... the patch I posted just drops messages. It does not change or
return any new return values.

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
