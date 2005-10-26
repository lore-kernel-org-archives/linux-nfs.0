From: Peter Staubach <staubach@redhat.com>
Subject: Re: Data coherency trouble with multiple	clients,	on2.6.14-rc5
Date: Wed, 26 Oct 2005 15:53:13 -0400
Message-ID: <435FDEA9.5060706@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E288E5A5@exsvl02.hq.netapp.com>	 <1130345451.8852.7.camel@lade.trondhjem.org>  <435FCECF.2090800@redhat.com> <1130353693.8859.21.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	Charles Duffy <ccd@mailcall.com.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUrL2-0005az-MW
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 12:53:32 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EUrKy-0001dR-AC
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 12:53:29 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1130353693.8859.21.camel@lade.trondhjem.org>
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

>on den 26.10.2005 klokka 14:45 (-0400) skreiv Peter Staubach:
>
>  
>
>>It seems to me that the policy should be to allow cache 
>>validation/invalidation
>>unless the file is mmap'd for writing or if there are active WRITEs 
>>outstanding.
>>Simply having the file open for write should not affect the consistency 
>>model.
>>    
>>
>
>That is what we did for 2.4.x, but what kind of extra guarantees does
>that really bring you? You cannot actually rely on it to provide
>stronger caching semantics than the close-to-open case.
>

This brings lots of extra guarantees, actually.  Just because the file is
open for writing does not mean that there are any dirty pages hanging
around waiting to be written.  And, even if there are, they will get
flushed when the conflict is detected.  Last there one there wins.  This
is even the policy when local processes conflict on the same file in the
same region.

This policy would address the situation that was reported here.

This policy will definitely result in _much_ stronger caching semantics
than does close-to-open.  These two policies together can usually result
in reasonable cache consistency, enough for most applications.  Applications
which need stronger cache consistency should be advisory locking in order
to synchronize access to the file.

       ps


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
