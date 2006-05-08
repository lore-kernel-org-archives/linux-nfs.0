From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd problem
Date: Mon, 08 May 2006 00:36:10 -0400
Message-ID: <1147062970.16861.24.camel@lade.trondhjem.org>
References: <OF668502A9.2BC37D4F-ON88257167.001B598B-88257167.001BB4D0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdEzD-0001BZ-Mi
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 16:17:55 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FcxTy-0008Ni-Ne
	for nfs@lists.sourceforge.net; Sun, 07 May 2006 21:36:30 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FcxTx-0003UZ-Bm
	for nfs@lists.sourceforge.net; Sun, 07 May 2006 21:36:30 -0700
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF668502A9.2BC37D4F-ON88257167.001B598B-88257167.001BB4D0@us.ibm.com>
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

On Sat, 2006-05-06 at 22:07 -0700, Marc Eshel wrote:
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote on 05/06/2006 09:38:26 
> PM:
> 
> > On Fri, 2006-05-05 at 22:01 -0700, Marc Eshel wrote:
> > > Hi Trond,
> > > I see a problem testing lockd with 2.6.16-CITI_NFS4_ALL-2,  I see that 
> you 
> > > made few changes in lockd, so let me describe it and see if can recall 
> any 
> > > changes that might cause the following problem.
> > > 
> > > I think that the source of the problem is that 2 clients from 2 
> different 
> > > machine end up with the same fl_pid on the lockd server.
> > 
> > It looks as if nlmsvc_lookup_block() fails to check the ip address of
> > the request. That is not a new bug: it has been there for a few years...
> > 
> > Cheers,
> >   Trond
> > 
> 
> The following patch seem to fix the problem. Do you see any reason not to 
> include fl_owner in the compare?
> Marc.

Since fl_owner is just set to be a pointer to the struct nlm_host, then
that should indeed be fully equivalent to checking the ip address of the
client.

Can you resend this patch to me with a changelog description and a
signed-off-by line, please?

Cheers,
  Trond

 
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index 588c02a..0d44ad9 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -232,6 +232,7 @@ static __inline__ int
>  nlm_compare_locks(const struct file_lock *fl1, const struct file_lock 
> *fl2)
>  {
>         return  fl1->fl_pid   == fl2->fl_pid
> +            && fl1->fl_owner == fl2->fl_owner
>              && fl1->fl_start == fl2->fl_start
>              && fl1->fl_end   == fl2->fl_end
>              &&(fl1->fl_type  == fl2->fl_type || fl2->fl_type == F_UNLCK);



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
