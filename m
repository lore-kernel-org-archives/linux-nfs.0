From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Performance: NFS v3  mounting with 'noac' option
Date: Thu, 08 Mar 2007 12:06:05 -0500
Message-ID: <EXNANE01pH71yEXUIEA00000088@exnane01.hq.netapp.com>
References: <EXNANE0169aZbLAX3cf00000085@exnane01.hq.netapp.com>
	<580880.57331.qm@web56613.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
To: AK <amithl_prem@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPM4b-0002rr-4U
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 09:06:54 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPM4a-0005ye-UP
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 09:06:39 -0800
In-Reply-To: <580880.57331.qm@web56613.mail.re3.yahoo.com>
References: <EXNANE0169aZbLAX3cf00000085@exnane01.hq.netapp.com>
	<580880.57331.qm@web56613.mail.re3.yahoo.com>
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

At 11:52 AM 3/8/2007, AK wrote:
>Hmmm..
>Tom & Peter, thank you for feedbacks ...
>
>I agree, but when I read through the web and other
>doucmentation ... I found that if NFS's local caching
>is enable, doing a parallel IO on a file is a problem
>some, because there is no global synchronization.

I'm sure Peter will jump in too - the point is you *do* have global
synchronization, from the locks. And in addition, modern clients
know that locking requires them to treat their caches differently,
and they handle these cases.

This did not used to be the case in all NFS clients, but any Linux
client has for quite some time handled this correctly. The only
reason to use noac today is to force clients to do no caching
when they are performing shared writes and are incapable of,
or refuse to do, locking. And even then, it's risky in the extreme.
In addition to being slow.

>Please correct me if I am wrong. I believe GFS works
>that way and we don't need to turn off caching there. 
>
>With the current setup when the user runs the MPI I/O
>program, he runs into following errors.
>
>File locking failed in ADIOI_Set_lock. If the file
>system is NFS, you need to use NFS version 3, ensure
>that the lockd daemon is running on all the machines,
>and mount the directory with the 'noac' option (no
>attribute caching).

If the app is failing to take a lock, yes fix it. But don't take
the second part of the advice.

Remind us again - what client are you using? Some of them do
not start the client's locking automatically. Perhaps that's the
case with yours.

>
>Is there an alternative to this ?? One more thing
>since we have nfs on our rocks cluster, the nfsd,
>rpc.statd etc are not started on the compute nodes
>...will starting this help the file locking ??

You do not want or need the nfsd on the compute nodes. But you
do need the rpc.statd. If it wasn't started automatically, then either
you are running a version that has it integrated in the kernel, or you
have to perform additional client setup. Let us know that client
version...

Tom.

>
>~thank you!
>
>
>--- "Talpey, Thomas" <Thomas.Talpey@netapp.com> wrote:
>
>> At 11:13 AM 3/8/2007, Peter Staubach wrote:
>> >AK wrote:
>> >> "To use ROMIO on NFS, file locking with fcntl
>> must
>> >> work correctly on the NFS installation. On some
>> >> installations, fcntl locks don't work. To get
>> them to
>> >> work, you need to use Version 3 of NFS, ensure
>> that
>> >> the lockd daemon is running on all the machines,
>> and
>> >> have the system administrator mount the NFS file
>> >> system with the "noac" option (no attribute
>> caching).
>> >> Turning off attribute caching may reduce
>> performance,
>> >> but it is necessary for correct behavior."
>> >
>> >I think that I would assume that fcntl style
>> locking works on all current
>> >implementations, that this is not NFS version
>> dependent, and also that
>> >"noac" is not required in combination with the
>> locking in order to get
>> >correct behavior.
>> 
>> Ouch - I agree with Peter, this advice is way, way
>> out of date.
>> <http://www-unix.mcs.anl.gov/romio/>
>> <http://www-unix.mcs.anl.gov/romio/nfs-instr.txt>
>> 
>> >"The following are some instructions we received
>> from Ian Wells of HP
>> >for setting the noac option on NFS. We have not
>> tried them
>> >ourselves. We are including them here because you
>> may find 
>> >them useful. Note that some of the steps may be
>> specific to HP
>> >systems, and ..."
>> 
>> Leave noac alone, the Linux client will do the right
>> thing with
>> its cache when locking is available.
>> 
>> Tom.
>> 
>> 
>
>
>
> 
>______________________________________________________________________
>______________
>Now that's room service!  Choose from over 150,000 hotels
>in 45,000 destinations on Yahoo! Travel to find your fit.
>http://farechase.yahoo.com/promo-generic-14795097


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
