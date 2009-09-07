From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: how to cleanly shutdown NFS without risk of hanging.
Date: Mon, 07 Sep 2009 10:18:28 -0400
Message-ID: <1252333108.5172.17.camel@heimdal.trondhjem.org>
References: <19108.34796.342633.805371@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:41256 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752911AbZIGOS3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Sep 2009 10:18:29 -0400
In-Reply-To: <19108.34796.342633.805371-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-09-07 at 14:11 +1000, Neil Brown wrote:
> Hi Trond et al
> 
> The problem is this:
>  If I run 'shutdown' while there are mounted NFS filesystems
>   from servers that are accessible and working, then I want
>   any last minute changes to be flushed through to the server(s).
>  If I run 'shutdown' while there are mounted NFS filesystems
>   but the servers are not accessible, whether because they are dead,
>   or because I pulled my network cable, or I've walked out of range
>   of my Wifi access point, then I don't want 'shutdown' to hang
>   indefinitely, but I want to it complete in a reasonable time.
> 
> I don't think meeting both of those goals is currently possible with
> Linux NFS.
> 
> I've been trying to think how to solve it and the only solution that
> seems at all robust is to somehow switch NFS mounts to 'soft' as part
> of the shutdown process.  That way things will get flushed if
> possible, but won't cause umount or sync to hang indefinitely -
> exactly what I want.
> 
> I can see two ways to achieve this.
> One is to allow "-o remount" to change the soft/hard flag.
> I think it would be easy enough to change ->cl_softrtry, but
> setting RPC_TASK_SOFT on each task would be awkward.
> Maybe we could change RPC_IS_SOFT() to something like:
>   (((t)->tk_flags & RPC_TASK_SOFT) || (t)->tk_client->cl_softrtry)
> ??
> 
> The other approach with be to introduce some global flag (a sysctl
> or module parameter??) which forces all tasks to be 'soft'.
> 
> The latter would be easier to plug in to the shutdown sequence and
> would equally apply to filesystems that have already been
> lazy-unmounted (you cannot remount those filesystems).
> 
> The former seems more in keeping with the way things are usually done,
> but is a little more complex for the shutdown scripts and doesn't help
> if someone lazy-unmounted a filesystem.
> 
> Of course we could do both.
> 
> Do you have any thoughts about this before I try implementing
> something?

I think that the ability to remount to 'soft', and possibly also to
change the timeout parameters could be very helpful even in a
non-shutdown situation.

The former should be very easy: it wouldn't take much effort to set the
RPC_TASK_SOFT flag by looping over the 'rpc_client->cl_tasks' list (see
rpc_killall_tasks()).
If you want to do this for all RPC clients, then we can do that too.
That's just a question of looping over the 'all_clients' list and
applying the above recipe to each rpc_client.

Changing the timeout parameters on existing tasks might not be possible,
but we could at least allow the user to change the default timeout on
the rpc_client...

Cheers
  Trond

