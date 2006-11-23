From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC] Change filesystem mount without
	disconnecting	clients
Date: Thu, 23 Nov 2006 14:35:56 -0800
Message-ID: <4566224C.2070108@google.com>
References: <4563C1A4.5060608@google.com>
	<1164219346.5694.31.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Robert Nelson <rlnelson@google.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GnNB0-0002hj-3D
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 14:36:15 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GnNB1-00081R-A6
	for nfs@lists.sourceforge.net; Thu, 23 Nov 2006 14:36:15 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1164219346.5694.31.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
>> The suspend is accomplished by taking a write lock on the export cache's
>> hash_sem, which by fortuitous circumstance encloses all nfs transaction
>> processing.  We then flush the export cache, driving the underlying
>> filesystem mount count down to one, in which state it can be unmounted.
>> Holding the hash_sem prevents mountd from reloading the export cache.  To
>> resume, we just release the write lock.
> 
> Definitely not the correct way to do this. Causing the NFS server to
> hang for long periods of time will, for instance, cause all NFSv4 state
> to be unnecessarily lost, forcing a full state recovery. It will also
> cause UDP clients to flood the network with retries.

What is a long period of time in this context?  This suspend is only
supposed to last a second or two while we mount the new filesystem.
Will we really start losing v4 state in that time?

We have in mind to reduce the duration of the suspend to practically
nothing eventually, by mounting the new filesystem _before_ suspending.
The suspend latency in this case would be just a few milliseconds, plus
the time to suspend the longest running filesystem transaction.

We also don't suspend rpc receive, just rpc execute, which gives us a
little more breathing room before all the nfsds block on processing.  We
could go a little further in that direction by tweaking the nfsd flow
to keep receiving requests even while processing is blocked.  But maybe
we really still need to do...

> Ideally, you want to be returning NFS3ERR_JUKEBOX to the NFSv3 clients
> (or NFS4ERR_DELAY for NFSv4) in order to request that they back off and
> retry the operation later. For some operations that don't involve files
> (e.g. the NFSv4 RENEW requests, NULL RPC pings) you may actually want to
> process the request despite the disk being offline.

Ah, thanks, this will solidify the behaviour without changing the basic
approach.

Regards,

Daniel

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
