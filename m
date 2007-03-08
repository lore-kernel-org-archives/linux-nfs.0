From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Performance: NFS v3  mounting with 'noac' option
Date: Thu, 08 Mar 2007 11:19:46 -0500
Message-ID: <EXNANE0169aZbLAX3cf00000085@exnane01.hq.netapp.com>
References: <121929.1837.qm@web56610.mail.re3.yahoo.com>
	<45F03624.1000207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: AK <amithl_prem@yahoo.com>, Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPLLa-0004Kf-TP
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 08:20:07 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPLLb-0003nR-QZ
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 08:20:09 -0800
In-Reply-To: <45F03624.1000207@redhat.com>
References: <121929.1837.qm@web56610.mail.re3.yahoo.com>
	<45F03624.1000207@redhat.com>
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

At 11:13 AM 3/8/2007, Peter Staubach wrote:
>AK wrote:
>> "To use ROMIO on NFS, file locking with fcntl must
>> work correctly on the NFS installation. On some
>> installations, fcntl locks don't work. To get them to
>> work, you need to use Version 3 of NFS, ensure that
>> the lockd daemon is running on all the machines, and
>> have the system administrator mount the NFS file
>> system with the "noac" option (no attribute caching).
>> Turning off attribute caching may reduce performance,
>> but it is necessary for correct behavior."
>
>I think that I would assume that fcntl style locking works on all current
>implementations, that this is not NFS version dependent, and also that
>"noac" is not required in combination with the locking in order to get
>correct behavior.

Ouch - I agree with Peter, this advice is way, way out of date.
<http://www-unix.mcs.anl.gov/romio/>
<http://www-unix.mcs.anl.gov/romio/nfs-instr.txt>

>"The following are some instructions we received from Ian Wells of HP
>for setting the noac option on NFS. We have not tried them
>ourselves. We are including them here because you may find 
>them useful. Note that some of the steps may be specific to HP
>systems, and ..."

Leave noac alone, the Linux client will do the right thing with
its cache when locking is available.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
