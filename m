From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: NFSv3 blocking locks broken in 2.6.7
Date: Tue, 17 Aug 2004 20:38:10 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF35B34F68.0EE4F93D-ON88256EF4.00138C8D-88256EF4.0013F948@us.ibm.com>
References: <OF9F656799.5FEFBB07-ON88256ED4.0072FC79-88256ED4.0073FD3C@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <OF9F656799.5FEFBB07-ON88256ED4.0072FC79-88256ED4.0073FD3C@LocalDomain>
To: NFS@lists.sourceforge.net
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





I just tried the latest 2.6.8 kernel and the following problem is still
there.

Marc Eshel/Almaden/IBM wrote on 07/17/2004 02:11:22 PM:

> Hi,
>
> There appears to be a problem with blocking locks granted by lockd
> (observed on 2.6.7 and some previous versions of 2.6). An NFS client
> waiting for a blocking lock unlocks the file incorrectly right after
> being granted the lock even though the application still holds the
> lock; thereby allowing another NFS client or local fcntl locks to be
> granted. This problem will not manifest itself while using two
> processes from the same NFS client because of the local locking on
> the client machine.
>
> The problem can be easily reproduced using two different NFS client
> machines and issuing the following sequence of locking calls (assume
> that /mnt is the NFS mount point on both NFS clients in the example):
>
> Client 1: fcntl(F_SETLK) /mnt/f1 granted and held
> Client 2: fcntl(F_SETLKW) /mnt/f1 blocked
> Client 1: fcntl(F_UNLCK) /mnt/f1 unlocked on Machine 1; granted on
Machine 2
> Client 2: After a delay, lock granted and held
> Client 1: fcntl(F_SETLK) /mnt/f1 granted (should be DENIED)
>
> The problem also occurs when the first process is executing the
> fcntl locks locally.
>
> Thanks, Marc.



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
