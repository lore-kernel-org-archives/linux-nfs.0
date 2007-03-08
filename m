From: AK <amithl_prem@yahoo.com>
Subject: Re: Performance: NFS v3  mounting with 'noac' option
Date: Thu, 8 Mar 2007 08:52:14 -0800 (PST)
Message-ID: <580880.57331.qm@web56613.mail.re3.yahoo.com>
References: <EXNANE0169aZbLAX3cf00000085@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPLqo-00014e-ML
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 08:52:22 -0800
Received: from web56613.mail.re3.yahoo.com ([66.196.97.57])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HPLqo-0002ny-CX
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 08:52:24 -0800
In-Reply-To: <EXNANE0169aZbLAX3cf00000085@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hmmm..
Tom & Peter, thank you for feedbacks ...

I agree, but when I read through the web and other
doucmentation ... I found that if NFS's local caching
is enable, doing a parallel IO on a file is a problem
some, because there is no global synchronization.
Please correct me if I am wrong. I believe GFS works
that way and we don't need to turn off caching there. 

With the current setup when the user runs the MPI I/O
program, he runs into following errors.

File locking failed in ADIOI_Set_lock. If the file
system is NFS, you need to use NFS version 3, ensure
that the lockd daemon is running on all the machines,
and mount the directory with the 'noac' option (no
attribute caching).

Is there an alternative to this ?? One more thing
since we have nfs on our rocks cluster, the nfsd,
rpc.statd etc are not started on the compute nodes
...will starting this help the file locking ??

~thank you!


--- "Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:

> At 11:13 AM 3/8/2007, Peter Staubach wrote:
> >AK wrote:
> >> "To use ROMIO on NFS, file locking with fcntl
> must
> >> work correctly on the NFS installation. On some
> >> installations, fcntl locks don't work. To get
> them to
> >> work, you need to use Version 3 of NFS, ensure
> that
> >> the lockd daemon is running on all the machines,
> and
> >> have the system administrator mount the NFS file
> >> system with the "noac" option (no attribute
> caching).
> >> Turning off attribute caching may reduce
> performance,
> >> but it is necessary for correct behavior."
> >
> >I think that I would assume that fcntl style
> locking works on all current
> >implementations, that this is not NFS version
> dependent, and also that
> >"noac" is not required in combination with the
> locking in order to get
> >correct behavior.
> 
> Ouch - I agree with Peter, this advice is way, way
> out of date.
> <http://www-unix.mcs.anl.gov/romio/>
> <http://www-unix.mcs.anl.gov/romio/nfs-instr.txt>
> 
> >"The following are some instructions we received
> from Ian Wells of HP
> >for setting the noac option on NFS. We have not
> tried them
> >ourselves. We are including them here because you
> may find 
> >them useful. Note that some of the steps may be
> specific to HP
> >systems, and ..."
> 
> Leave noac alone, the Linux client will do the right
> thing with
> its cache when locking is available.
> 
> Tom.
> 
> 



 
____________________________________________________________________________________
Now that's room service!  Choose from over 150,000 hotels
in 45,000 destinations on Yahoo! Travel to find your fit.
http://farechase.yahoo.com/promo-generic-14795097

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
