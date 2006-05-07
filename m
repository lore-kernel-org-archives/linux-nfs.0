From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: lockd problem
Date: Sat, 6 May 2006 22:07:05 -0700
Message-ID: <OF668502A9.2BC37D4F-ON88257167.001B598B-88257167.001BB4D0@us.ibm.com>
References: <1146976706.14133.63.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdF1h-00019V-HK
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 16:20:29 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FcbOk-0007Fr-7O
	for nfs@lists.sourceforge.net; Sat, 06 May 2006 22:01:38 -0700
Received: from e3.ny.us.ibm.com ([32.97.182.143])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FcbOi-0004oB-QX
	for nfs@lists.sourceforge.net; Sat, 06 May 2006 22:01:38 -0700
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4751Tjf007252
	for <nfs@lists.sourceforge.net>; Sun, 7 May 2006 01:01:29 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4751RXQ213364
	for <nfs@lists.sourceforge.net>; Sun, 7 May 2006 01:01:29 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k4751RLe013552
	for <nfs@lists.sourceforge.net>; Sun, 7 May 2006 01:01:27 -0400
In-Reply-To: <1146976706.14133.63.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Trond Myklebust <trond.myklebust@fys.uio.no> wrote on 05/06/2006 09:38:26 
PM:

> On Fri, 2006-05-05 at 22:01 -0700, Marc Eshel wrote:
> > Hi Trond,
> > I see a problem testing lockd with 2.6.16-CITI_NFS4_ALL-2,  I see that 
you 
> > made few changes in lockd, so let me describe it and see if can recall 
any 
> > changes that might cause the following problem.
> > 
> > I think that the source of the problem is that 2 clients from 2 
different 
> > machine end up with the same fl_pid on the lockd server.
> 
> It looks as if nlmsvc_lookup_block() fails to check the ip address of
> the request. That is not a new bug: it has been there for a few years...
> 
> Cheers,
>   Trond
> 

The following patch seem to fix the problem. Do you see any reason not to 
include fl_owner in the compare?
Marc.
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 588c02a..0d44ad9 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -232,6 +232,7 @@ static __inline__ int
 nlm_compare_locks(const struct file_lock *fl1, const struct file_lock 
*fl2)
 {
        return  fl1->fl_pid   == fl2->fl_pid
+            && fl1->fl_owner == fl2->fl_owner
             && fl1->fl_start == fl2->fl_start
             && fl1->fl_end   == fl2->fl_end
             &&(fl1->fl_type  == fl2->fl_type || fl2->fl_type == F_UNLCK);


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
