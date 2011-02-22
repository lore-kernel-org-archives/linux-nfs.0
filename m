Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:38198 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153Ab1BVRFQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Feb 2011 12:05:16 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.72)
	(envelope-from <wferi@niif.hu>)
	id 1Prvfn-0006aF-5q
	for linux-nfs@vger.kernel.org; Tue, 22 Feb 2011 18:05:15 +0100
From: Ferenc Wagner <wferi@niif.hu>
To: linux-nfs@vger.kernel.org
Subject: Re: server does not abort grace period
References: <87wrl6ix2i.fsf@tac.ki.iif.hu> <87mxlpw4cv.fsf@tac.ki.iif.hu>
	<20110222011144.GA18424@fieldses.org>
Date: Tue, 22 Feb 2011 18:05:14 +0100
In-Reply-To: <20110222011144.GA18424@fieldses.org> (J. Bruce Fields's message
	of "Mon, 21 Feb 2011 20:11:44 -0500")
Message-ID: <878vx8huet.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

"J. Bruce Fields" <bfields@fieldses.org> writes:

First of all, thank you very much for the detailed and useful reply!

> On Mon, Feb 21, 2011 at 08:54:24PM +0100, Ferenc Wagner wrote:
>
>> Ferenc Wagner <wferi@niif.hu> writes:
>> 
>>> We're running 2.6.32 (Debian squeeze) NFS4 server and clients.  The
>>> server boots and runs purely from SAN, so we can start it on different
>>> computers.  In case of such "hardware failovers" I'd expect the clients
>>> to quickly reclaim their locks (if any) and thus the server to abort
>>> it's 90-second grace period early.  However, this does not happen,
>>> ruining our HA like, totally.
>>>
>>> So, the questions: is the functionality of aborting the grace period
>>> early missing from version 2.6.32 of the Linux kernel?  If yes, is it
>>> present in any kernel version?  If it should work, could someone offer
>>> some advice on debugging it?  If it isn't supported, what's the
>>> best practice of providing highly available NFSv4 today?
>> 
>> Could somebody please share any related wisdom?  Pretty please?
>> In short, how to fight grace period in a HA NFS4 setup?
>> Decreasing it (of course after cutting the lock lease time) seems a
>> rather big hammer, I'd like to avoid using it if reasonably possible.
>
> The NFSv4.0 protocol doesn't provide any way for clients to tell the
> server that they have finished recovering; as long as *any* clients
> held state on the previous server instance, the new server is stuck
> waiting out the whole grace period.  Some things we could do:
>
> 	- We could at least recognize the case where *no* clients held
> 	  state before, and end the grace period early in that case.

Would this mean that /var/lib/nfs/v4recovery is empty on the server?
Actually, it contains a hex-named empty directory, sometimes two (we're
running with two clients at the moment).

> 	- In the NFSv4.1 case there is a "reclaim complete" rpc that
> 	  clients are required to send.  Currently we don't take
> 	  advantage of that to end the grace period early, but we
> 	  should.  That's no help for 4.0 clients.

/proc/fs/nfsd/versions shows +4.1 on the server, does this mean that
nfs4 type Linux client mounts should issue "reclaim complete"?  I see
that it won't help anyway at the moment, lacking server support, just
out of interest...

> 	- We could record a count of all locks/opens held in stable
> 	  storage and use that to decide when a client is done
> 	  recovering.  That would be complicated and risk slowing down
> 	  normal opens and locks a lot.

And the "reclaim complete" client RPC seems must better anyway, as the
server and the client may get out of sync in case of an unclean client
shutdown.

> I don't think decreasing the lease time would be so terrible.  Perhaps
> the default should even be a little less.

Fine, then.  Does the Linux nfs server implementation use the lease time
of the previous server instance as grace period on startup, or does it
simply take whatever it finds in /proc/fs/nfsd/nfsv4leasetime?
-- 
Thanks for taking time,
Feri.
