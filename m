From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: Server bottleneck(?) due to large record write() buffer size from
 client app
Date: Wed, 20 Aug 2008 14:14:39 +1000
Message-ID: <48AB9A2F.1050005@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from note.orchestra.cse.unsw.EDU.AU ([129.94.242.24]:60146 "EHLO
	note.orchestra.cse.unsw.EDU.AU" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750992AbYHTEar (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2008 00:30:47 -0400
Received: From
	[203.143.160.170] ([203.143.160.170] == chaos.ken.nicta.com.au) (auth-user shehjart) (cse-authentic-sender shehjart)
	(for <linux-nfs@vger.kernel.org>) By note With Smtp ;
	Wed, 20 Aug 2008 14:30:44 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All

If I understand it correctly, there are three points at which linux
nfs client sends the NFS write request:

1. Inside nfs_flush_incompatible() where it needs to send writes as
stable because the pages are required for new write request from an
application. I think this happens only in case of high memory
pressure.

2. Inside nfs_file_write(), when nfs_do_fsync() is called if the file
was opened with O_SYNC.

3. When the file is closed, any remaining writes are flushed out as
unstable and then the final commit is sent.

In some of the tests I am running, I see drastic fall in write
throughput between a record size(.. i.e. the size of the buffer handed
to the write() syscall..) of 32Kbytes and a record size of say 50
Mbytes and 100 Mbytes. This fall is seen for NFS wsize values of 32k,
64k, 1Mb and with different tcp_slot_table_entries values of 16, 64,
96 and 128. The test files are opened without O_SYNC over a sync
mounted NFS. The client is a big machine with 16 logical processors
and 16Gigs of RAM.

I suspect that the fall happens because the NFS client stack sends all
the NFS writes as unstable till the file gets closed, when it sends
the final commit request. Since the write() record sizes are pretty
big the throughput drops because the final commit takes
extra-ordinarily long for the whole 100Megs to commit at the server
resulting in lower aggregate throughput.

Is this understanding correct?

Can this behaviour be modified so that the client uses the knowledge
of the write() buffer size, by initiating writeback before the full
100megs needs to be committed to the server in one go?

Thanks
Shehjar
