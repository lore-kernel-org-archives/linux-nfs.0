From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lockd recovery not working on RH with 2.6 kernel
Date: Fri, 19 Nov 2004 12:50:10 -0500
Message-ID: <419E3252.3040602@RedHat.com>
References: <OF573E8465.7E3D5CC0-ON88256F49.0064BB5C-88256F49.00698B56@us.ibm.com>	 <419CD343.4000600@RedHat.com> <1100882099.11209.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1100882099.11209.8.camel@lade.trondhjem.org>
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

>to den 18.11.2004 Klokka 11:52 (-0500) skreiv Steve Dickson:
>  
>
>>Well it appears things are a bit broken. Here is a client side patch that
>>enables the client to reclaim locks on a rebooted server.
>>
>>The two main issues were nlm4svc_decode_reboot() not setting
>>the protocol which cause the nlm_host structure not to be found
>>and two, making nlmclnt_reclaim() retry when the portmapper was up
>>but lockd had not made it yet.... I also fixed a debugging
>>statement and well as added a couple... that I found useful....
>>    
>>
>
>Yep. Good work!
>  
>
cool... can I assuming the patch will be headed to one of the upstream 
kernels soon?

>>Unfortunately this reclaim code freaks out the linux server, causing it
>>to send two back-to-back messages (both using the same xid) that
>>fails and then grant the lock.... It seems the dentry_open() call
>>(in nfsd_open()) is returning 30000 error value. Its not clear why or
>>what a 30000 value means....  I'm still looking in to that, but this code
>>was tested with both a Neapps filer and Solaris 10 server which seem
>>to work fine..
>>    
>>
>
>30000 ???? All kernel errors should be < 1000. Is this the perhaps the
>bug with the unintialized variable in the mountd upcall code? I believe
>the attached patch has already been committed to the nfs-utils CVS tree.
>  
>
Well after further review.... dentry_open() is not the one failing with 
an error
code of 30000, its fh_verify() that's failing with 30000 which means 
nfserr_dropit.
Basically what this means is exp_find()  is returning EAGAIN because the 
there
is an upcall is already in process (or the cache is not yet fully 
primed)....

Unfortunately the NLM protocol does not support a EAGAIN notion and the way
the NLM rpc routines are setup, is does not seem possible to simply 
svc_drop
NLM messages....

So I've pinged Neil on how he would like to hand this....

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
