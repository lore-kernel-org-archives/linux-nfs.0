From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lockd recovery not working on RH with 2.6 kernel
Date: Wed, 17 Nov 2004 14:58:17 -0500
Message-ID: <419BAD59.80708@RedHat.com>
References: <OF573E8465.7E3D5CC0-ON88256F49.0064BB5C-88256F49.00698B56@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <OF573E8465.7E3D5CC0-ON88256F49.0064BB5C-88256F49.00698B56@us.ibm.com>
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

Marc Eshel wrote:

>The problem is that after the NFS sever machine reboots its statd sends a
>notification to all NFS clients that had locking activity but the clients
>fail to reclaim their locks.
>  
>
Looking into this... either I'm missing some really crucial patches or
lock recover with the 2.6.9/10 kernels is really broken.  I'm really
hoping its the former.... :) but there is what I'm seeing...

The client takes a lock. The server is rebooted (both 2.6.9 kernels).
The server statd sends the SM_NOTIFY to the client statd, and
client statd notifies the kernel, BUT not with enough information
for the kernel to find the granted lock, so the lock request is blown
off....

The details: since nlm4svc_decode_reboot() does not set argp->vers
or argp->proto, nlm_lookup_host() does not find the outstanding nlm_host
pointer so a new one is created, which causes both reclaimer() and
nlmclnt_mark_reclaim() not to find the file_lock pointer....

Now giving the kernel the correct information (i.e. setting  both 
argp->vers
and argp->proto to the correctly values), the correct nlm_host pointer is
found which cause the client to query the server portmapper for lockd's 
port.
Unfortunately, lockd is not up yet so the portmap query fails and again,
the request is blown off....

The details:  nlmclnt_reclaim() calls nlmclnt_call() which fails with
-EACCES because the portmapper is up but lockd is not.

Now when a retry mechanism is added to nlmclnt_reclaim() which
ignores the EACCES, a lock request, with the reclaim bit set, is
sent to the server. Unfortunately, the server (for a reason I have yet
to figure out) denies the lock but then immediately grants the lock.
The really bizarre thing is both server messages have the same XID!

Is anybody else seeing these type of oddities with lock recovery?

SteveD.





-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
