From: Neil Brown <neilb@suse.de>
Subject: how to cleanly shutdown NFS without risk of hanging.
Date: Mon, 7 Sep 2009 14:11:24 +1000
Message-ID: <19108.34796.342633.805371@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58902 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304AbZIGEKc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Sep 2009 00:10:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Trond et al

The problem is this:
 If I run 'shutdown' while there are mounted NFS filesystems
  from servers that are accessible and working, then I want
  any last minute changes to be flushed through to the server(s).
 If I run 'shutdown' while there are mounted NFS filesystems
  but the servers are not accessible, whether because they are dead,
  or because I pulled my network cable, or I've walked out of range
  of my Wifi access point, then I don't want 'shutdown' to hang
  indefinitely, but I want to it complete in a reasonable time.

I don't think meeting both of those goals is currently possible with
Linux NFS.

I've been trying to think how to solve it and the only solution that
seems at all robust is to somehow switch NFS mounts to 'soft' as part
of the shutdown process.  That way things will get flushed if
possible, but won't cause umount or sync to hang indefinitely -
exactly what I want.

I can see two ways to achieve this.
One is to allow "-o remount" to change the soft/hard flag.
I think it would be easy enough to change ->cl_softrtry, but
setting RPC_TASK_SOFT on each task would be awkward.
Maybe we could change RPC_IS_SOFT() to something like:
  (((t)->tk_flags & RPC_TASK_SOFT) || (t)->tk_client->cl_softrtry)
??

The other approach with be to introduce some global flag (a sysctl
or module parameter??) which forces all tasks to be 'soft'.

The latter would be easier to plug in to the shutdown sequence and
would equally apply to filesystems that have already been
lazy-unmounted (you cannot remount those filesystems).

The former seems more in keeping with the way things are usually done,
but is a little more complex for the shutdown scripts and doesn't help
if someone lazy-unmounted a filesystem.

Of course we could do both.

Do you have any thoughts about this before I try implementing
something?

Thanks,
NeilBrown
