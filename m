Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from web65408.mail.ac4.yahoo.com ([76.13.9.28]:25457 "HELO
	web65408.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752321Ab1DEQcl convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Apr 2011 12:32:41 -0400
Message-ID: <521591.18062.qm@web65408.mail.ac4.yahoo.com>
Date: Tue, 5 Apr 2011 09:32:38 -0700 (PDT)
From: Andrew Klaassen <clawsoon@yahoo.com>
Subject: Re: Fwd: Prioritizing readdirplus/getattr/lookup
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <4104737B-ECEA-46F7-BD26-39241DB8EBAF@oracle.com>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--- On Mon, 4/4/11, Chuck Lever <chuck.lever@oracle.com> wrote:

> I suspect this is a result of the POSIX requirement
> that stat(2) must return mtime and size that reflects the
> very latest write to a file.  To meet this requirement,
> the client flushes all dirty data for a file before
> performing the GETATTR.
> 
> The Linux VM allows a large amount of dirty data
> outstanding when writing a file.  This means it could
> take quite a while before that GETATTR can be done.

I've done some more benchmarking, and in my case writes appear to *not* be the culprit.

Having the HPC farm only reading files (with noatime set everywhere, of course) actually makes "ls -l" over NFS slightly ~slower~.

Having the HPC farm only reading files that all fit in the server's cache makes "ls -l" over NFS yet slower.  (I watched iostat while this was running to make sure that nothing was being written to or read from disk.)

So I've eliminated the disk as a bottleneck, and (as per my earlier emails) I've eliminated the filesystem and VM system.

It really does look at this point like nfsd is the choke point.

Andrew


