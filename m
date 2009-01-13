Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47660 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754037AbZAMWbf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2009 17:31:35 -0500
Message-ID: <496D1642.6060608@redhat.com>
Date: Tue, 13 Jan 2009 17:31:30 -0500
From: Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Nick Piggin <nickpiggin@yahoo.com.au>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH] out of order WRITE requests
Content-Type: multipart/mixed;
 boundary="------------010508010907040906010009"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------010508010907040906010009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

Attached is a patch which addresses a continuing problem with
the NFS client generating out of order WRITE requests.  While
this is compliant with all of the current protocol
specifications, there are servers in the market which can not
handle out of order WRITE requests very well.  Also, this may
lead to sub-optimal block allocations in the underlying file
system on the server.  This may cause the read throughputs to
be reduced when reading the file from the server.

There has been a lot of work recently done to address out of
order issues on a systemic level.  However, the NFS client is
still susceptible to the problem.  Out of order WRITE
requests can occur when pdflush is in the middle of writing
out pages while the process dirtying the pages calls 
generic_file_buffered_write which calls
generic_perform_write which calls
balance_dirty_pages_rate_limited which ends up calling
writeback_inodes which ends up calling back into the NFS
client to writes out dirty pages for the same file that
pdflush happens to be working with.

The attached patch supplies synchronization in the NFS client
code itself.  The entry point in the NFS client for both of
the code paths mentioned is nfs_writepages, so serializing
there resolves this issue.

My testing, informal, showed no degradation in WRITE
throughput.

    Thanx...

       ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------010508010907040906010009
Content-Type: text/plain;
 name="sync_writes.devel"
Content-Disposition: attachment; filename="sync_writes.devel"
X-Mozilla-External-Attachment-URL: file:///Users/pgp/Downloads/sync_writes.devel
X-Mozilla-Altered: AttachmentDetached; date="Wed Jan 14 12:08:29 2009"

The original MIME headers for this attachment are:
Content-Type: text/plain;
 name="sync_writes.devel"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sync_writes.devel"


--------------010508010907040906010009--
