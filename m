Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:53493 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab1COQZD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 12:25:03 -0400
Subject: Re: problem with nfs latency during high IO
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D7B6DE5.8010008@imppc.org>
Date: Tue, 15 Mar 2011 12:24:40 -0400
Cc: <linux-nfs@vger.kernel.org>
Message-Id: <526EE4AA-ABD2-4452-9C3A-C000BD3CFC60@oracle.com>
References: <4D7B6DE5.8010008@imppc.org>
To: Judith Flo Gaya <jflo@imppc.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Judith-

On Mar 12, 2011, at 7:58 AM, Judith Flo Gaya wrote:

> Hello,
> 
> I was told some days ago that my problem with my NFS system is related to this bug, as the problem that I'm experiencing is quite similar.
> 
> The bug : https://bugzilla.redhat.com/show_bug.cgi?id=469848
> 
> The link itself explains quite well my issue, I'm just truing to copy a big file (36Gb) to my nfs server and when I try to get an ls -l command to the same folder where I'm copying data, the command gets stuck for some time. This amount of time changes from a few secs to SOME minutes (9' is the current record).
> I can live with some seconds of delay, but minutes is something quite unacceptable.
> 
> As this is an nfs server running on a red hat system (an HP ibrix x9300 with Red Hat 5.3 x86_64, kernel 2.6.18-128) I was told to apply the patch suggested from the bug on my clients.
> 
> Unfortunately my clients are running fedora core 14 (x86_64, kernel 2.6.35.6-45) and I can't find the file that they are referring to, the file fs/nfs/inode.c is not there and I can't find the rpm that contains it.
> 
> As the bug is a very very old one, I took it for granted that is already applied to fedora, but I wanted to make sure that it is looking at the file.
> 
> Can you help me on this? I'm I wrong in my supposition (is the patch really applied)? is it possible that my problem is somewhere else?

This sounds like typical behavior.

POSIX requires that the mtime and file size returned by stat(2) ('ls -l') reflect the most recent write(2).  On NFS, the server sets both of these fields.  If a client is caching dirty data, and an application does a stat(2), the client is forced to flush the dirty data so that the server can update mtime and file size appropriately.  The client then does a GETATTR, and returns those values to the requesting application.

The problem is that Linux caches writes aggressively.  That makes flushing before the GETATTR take a long time in some cases.  On some versions of Linux, it could be an indefinite amount of time; recently we added a bit of logic to make the GETATTR code path hold up additional application writes so it would be able to squeeze in the GETATTR to get a consistent snapshot of mtime and size.

Another issue is: what if other clients are writing to the file?  Those writes won't be seen on your client, either in the form of data changes or mtime/size updates, until your client's attribute cache times out (or the file is unlocked or closed).

The best you can do for now is to lower the amount of dirty data the client allows to be outstanding, thus reducing the amount of time it takes for a flush to complete.  This is done with a sysctl, I believe "vm.dirty_ratio," and affects all file systems on the client.  Alternately, the client file system in question can be mounted with "sync" to cause writes to go to the server immediately, but that has other significant performance implications.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

