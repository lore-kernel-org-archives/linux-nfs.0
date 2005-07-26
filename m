From: Peter Staubach <staubach@redhat.com>
Subject: Re: Configuration for NFSv3 only?
Date: Tue, 26 Jul 2005 08:52:15 -0400
Message-ID: <42E631FF.3050005@redhat.com>
References: <20050725223530.80613.qmail@web33915.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxOy3-0007u7-Sc
	for nfs@lists.sourceforge.net; Tue, 26 Jul 2005 05:55:31 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DxOy3-0003fH-NT
	for nfs@lists.sourceforge.net; Tue, 26 Jul 2005 05:55:32 -0700
To: Bill Johnstone <beejstone3@yahoo.com>
In-Reply-To: <20050725223530.80613.qmail@web33915.mail.mud.yahoo.com>
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

Bill Johnstone wrote:

>--- Peter Staubach <staubach@redhat.com> wrote:
>
>  
>
>>The answer to this question is that the portmapper protocol is
>>completely
>>separate from the NFS and related protocols such as nlockmgr and
>>mountd.
>>
>>There are newer versions of the protocol, 10000, which are now called
>>
>>rpcbind.
>>
>>But, the short answer, is that portmapper, version 2, is fine for
>>these 
>>purposes.
>>    
>>
>
>Does this separation of versions also apply to "status"?  The version
>given for that both on the client and server sides is "1".
>
>Is that OK for NFSv3 operation?
>

Hi.

Yes, version 1 for the status protocol is also fine and is not related 
to the
version of NFS, either 2 or 3, being used.  The NFS version 4 protocol is
self contained and does not use either the nlockmgr (network lock manager),
the mount, or the status protocols as part of the support required for it.

A little bit of information --

NFS version 2 uses either MOUNT versions 1 or 2.  The difference between
MOUNT version 1 and MOUNT version 2 is the addition of an operation to
retrieve POSIX pathconf information.

NFS version 2 uses either NLOCKMGR versions 1 or 3.  The difference between
versions 1 and 3 is the addition of some primitives for file sharing, ala
DOS.

NFS version 3 uses MOUNT version 3.  This version of the MOUNT protocol is
similar to the MOUNT version 1 protocol, but returns NFS version 3 file
handles instead of NFS version 2 file handles.

NFS version 3 uses NLOCKMGR version 4.  This version of the NLOCKMGR
protocol is similar to the NLOCKMGR version 3 protocol, but assumes that
the owner handle encapsulates an NFS version 3 file handle instead of an
NFS version 2 filehandle.

You might also notice two versions of a protocol called NFS_ACL.  This
protocol was designed in order to handle POSIX style ACLs.  It also
contains some extensions to handle generalized extended attributes.
In the marketplace, certain implementations of NFS version 2 will also
support NFS_ACL version 2.  Certain implementations of NFS version 3
will also support NFS_ACL version 3.  The corresponding version of NFS
uses the corresponding version of the NFS_ACL protocol.

There is support for the NFS_ACL version 3 protocol available in some
versions of Linux.

--

I hope that this is helpful.

       ps


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
