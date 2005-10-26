From: Peter Staubach <staubach@redhat.com>
Subject: Re: Data coherency trouble with	multiple	clients,	on2.6.14-rc5
Date: Wed, 26 Oct 2005 17:22:57 -0400
Message-ID: <435FF3B1.5030200@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E288E5A5@exsvl02.hq.netapp.com>	 <1130345451.8852.7.camel@lade.trondhjem.org> <435FCECF.2090800@redhat.com>	 <1130353693.8859.21.camel@lade.trondhjem.org> <435FDEA9.5060706@redhat.com> <1130360742.8859.56.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	Charles Duffy <ccd@mailcall.com.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUsjf-0001Lp-H5
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 14:23:03 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EUsjf-0005iD-4m
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 14:23:03 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1130360742.8859.56.camel@lade.trondhjem.org>
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

>on den 26.10.2005 klokka 15:53 (-0400) skreiv Peter Staubach:
>  
>
>>This brings lots of extra guarantees, actually.  Just because the file is
>>open for writing does not mean that there are any dirty pages hanging
>>around waiting to be written.  And, even if there are, they will get
>>flushed when the conflict is detected.  Last there one there wins.  This
>>is even the policy when local processes conflict on the same file in the
>>same region.
>>
>>This policy would address the situation that was reported here.
>>
>>This policy will definitely result in _much_ stronger caching semantics
>>than does close-to-open.  These two policies together can usually result
>>in reasonable cache consistency, enough for most applications.  Applications
>>which need stronger cache consistency should be advisory locking in order
>>to synchronize access to the file.
>>    
>>
>
>Sure, but the big issue here is how to actually detect conflicts (and
>avoid excessive false positives).
>
>  
>

I would say that it is better to be safe and then fast.  Some cache
invalidations for false positives are better than missing some which
were required.

>NFSv3 does in theory give you the option of detecting conflicts using
>weak cache consistency. In practice, write reordering and the fact that
>most servers violate the requirement given by RFC1813 that pre/post-op
>attributes should be atomic w.r.t. the main operation prevents you from
>closing the hole.
>NFSv2 and NFSv4 don't even have support for WCC, so your detection
>scheme ends up being very dependent on one particular version of NFS.
>
>  
>

Actually NFSv4 does have an attribute that the client can use, doesn't it?
Something like change_attr or some such?

The write reordering issue only exists for multiple concurrent operations
such as WRITE operations.  I will agree, that if the wcc_data for WRITE
operations is used, then many false positives will probably occur.  However,
useful and valid cache validations can be done using GETATTR or other
operations such as ACCESS or LOOKUP, even while a file is open for writing.

>Basically, what I'm saying is that as long as we cannot implement the
>above ideal, we should not be issuing promises to application developers
>that they can rely on it. O_DIRECT was specifically developed in order
>to give database implementers a reliable uncached I/O interface, and so
>that is what we should direct them towards.
>The worst thing to do when someone asks IMHO is to reply that "we can
>almost but not quite fix noac".
>

O_DIRECT is pretty much only useful to the database folks because of the
lack of readahead and write behind which kills performance.  They can
utilize O_DIRECT because they use multiple contexts or AIO to issue the
i/o requests.

The application developers are already aware of the loose cache consistency
that NFS offers.  This is not a reason to loosen it further though.  We
can and should do the best job that we can.  We have to make some 
assumptions
about how well NFS servers implement the correct semantics.  If an NFS
server is truly broken, then let's get that NFS server fixed.  Avoiding
useful semantics because some servers in the market may not get them
right seems self defeating to me and just futhers the myth that NFS is
not useful as a distributed file system.

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
