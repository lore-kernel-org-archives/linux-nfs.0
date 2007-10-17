From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH RFC 1/1] NLM GRANTED callback race
Date: Wed, 17 Oct 2007 12:44:38 -0400
Message-ID: <1192639478.7573.50.camel@heimdal.trondhjem.org>
References: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiC0G-0005vO-O3
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 09:44:16 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IiC0J-0008NO-L2
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 09:44:22 -0700
In-Reply-To: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Wed, 2007-10-17 at 09:36 -0400, Talpey, Thomas wrote:
> I've discovered a serious and somewhat interesting issue in the NLM
> client that's been present for quite a while. Basically, if an NLM server
> GRANTED callback arrives for a lock the client already holds, the client
> *rejects* the lock. This leads to incorrect behavior (since the server
> may give the lock to another process), but it also may lead to deadlock
> in the affected client when the next process is on the same machine;
> it means two processes are contending in the local locking code. We
> have seen this in the field recently.
> 
> I have a proposed fix (patch below), which adds further checking to
> the NLM callback to scan for held locks, if the callback does not find
> a blocked lock in the client's nlm_blocked list. If found, the client will
> *accept* the lock instead of rejecting it. We're testing the patch at
> high scale currently, an earlier version of the patch (for kernel 2.6.15)
> works well at extreme levels.
> 
> To see this, you need to have NLM lock contention, and enough
> network traffic to cause UDP NLM_GRANTED callbacks to be lost in
> the network. Typically, the client will retry the NLM_LOCK rpc after
> 30 seconds when this occurs. These retries often succeed, but there
> are still the old GRANTED callbacks floating around, either at the server
> or in the network itself. We can duplicate this in minutes at high load,
> even with server callback retry.
> 
> Comments?

So what will happen in this case if the NLM_GRANTED reply races with my
UNLOCK call to release the lock?

Servers have to perform consistency checks on NLM_GRANTED, or the
protocol will break. Once the client has been granted the lock via a
separate LOCK call, then the result of the NLM_GRANTED request _MUST_ be
ignored on the server.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
