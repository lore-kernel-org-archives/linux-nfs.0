From: Dale Stimson <DaleStimson@gmail.com>
Subject: Re: [PATCH] Short write in nfsd becomes a full write to the client
Date: Fri, 26 Jun 2009 21:24:49 -0700
Message-ID: <20090627042449.GC15665@cupro.opengvs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Shaw <dshaw-wh+mT2OhP0WF0gnf/s2wvA@public.gmane.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 68-185-24-58.static.mdfd.or.charter.com ([68.185.24.58]:43464
	"EHLO cupro.opengvs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743AbZF0Enf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Jun 2009 00:43:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 5 Mar 2009 20:16:14 -0500, David Shaw <dshaw-wh+mT2OhP0WF0gnf/s2wvA@public.gmane.org> wrote:
> If a filesystem being written to via NFS returns a short write count
> (as opposed to an error) to nfsd, nfsd treats that as a success for
> the entire write, rather than the short count that actually succeeded.
> 
> For example, given a 8192 byte write, if the underlying filesystem
> only writes 4096 bytes, nfsd will ack back to the nfs client that all
> 8192 bytes were written.  The nfs client does have retry logic for
> short writes, but this is never called as the client is told the
> complete write succeeded.
...
> Here is a patch to properly return the short write count to the
> client.
[patch elided]

I bring this to your attention so you may, if you choose, look into
this further:

Problem synopsis:
An old client (running RHL 9 with kernel "2.4.20-43.9.legacy")
attempts to seek on a file mounted over nfs.  The operation fails
with "Illegal seek" or "Input/Output error".  The server is running
Fedora 11 kernel-PAE-2.6.29.5-191.fc11.i686, which includes the
short write patch.  When this kernel is re-built without the short
write patch, everything works as before.

Detais are at
https://bugzilla.redhat.com/show_bug.cgi?id=508174

Caveats: I am specifically referring to the patch file
"linux-2.6-nfsd-report-short-writes.patch" as newly included in
Fedora's file kernel-2.6.29.5-191.fc11.src.rpm .  I can't vouch
that that patch file is identical to what was posted to this list
or merged for 2.6.30-rc1.

(As an aside, in this case, the client was attempting a simple gcc
compile and link.  The failing programs (invoked by fcc) were the
assember ("as)" and "ld".)
