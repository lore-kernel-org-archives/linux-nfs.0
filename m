From: Marc Eshel <eshel@almaden.ibm.com>
Subject: NFSv3 blocking locks broken in 2.6.7
Date: Tue, 24 Aug 2004 17:31:10 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFAF6A9C4E.27A9BF20-ON88256EFB.00020035-88256EFB.0002DABA@us.ibm.com>
References: <OF5D98042A.0F02E0AD-ON88256EF5.0003D053-88256EF5.00041A3D@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <OF5D98042A.0F02E0AD-ON88256EF5.0003D053-88256EF5.00041A3D@LocalDomain>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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





Hi Trond,

I have a question about the serialization of the nlm_blocked list. Is it
possible that the lockd thread will manipulate the list while a call is
made to nlmsvc_notify_blocked() on a different thread which is also
searching the nlm_blocked list?

Thanks, Marc.



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
