Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og110.obsmtp.com ([64.18.0.20]:50996 "HELO
	exprod5og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751562Ab0JUQso (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 12:48:44 -0400
Message-ID: <4CC06EE8.7010705@panasas.com>
Date: Thu, 21 Oct 2010 18:48:40 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: quanli gui <gqlxj1987@gmail.com>
CC: linux-pnfs <linux-nfs@vger.kernel.org>
Subject: Re: [pnfs] pnfs first write has very long delay
References: <AANLkTi=XSSM5+wmCrVzQrZF8rA81OLqDO_dMzUqwHc7g@mail.gmail.com>
In-Reply-To: <AANLkTi=XSSM5+wmCrVzQrZF8rA81OLqDO_dMzUqwHc7g@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-21 14:03, quanli gui wrote:
> When pnfs is mount on the client, I write a file to the mount dir by the
> first time. It must wait a very long time until the pnfs complete the write.
> When the operation waited, I dmesg the operation information. Find that
> NFS:     0 initiated write call (req 0:13/200809, 3035 bytes @ offset 49152)
> --> nfs4_setup_sequence clp c450a800 session c450ac00 sr_slotid 128
> --> nfs41_setup_sequence
> --> nfs4_find_slot used_slots=0007 highest_used=2 max_slots=16
> <-- nfs4_find_slot used_slots=000f highest_used=3 slotid=3
> <-- nfs41_setup_sequence slotid=3 seqid=1
> <-- nfs4_setup_sequence status=0
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=1 slotid=3 max_slotid=3
> cache_this=1
> filelayout_write_call_done new off 40960 orig offset 40960
> pnfs_writeback_done: Begin (status -10008)

What kind of DS are you using?
The 10008 error means that the DS returned NFS4ERR_DELAY
so we need to understand why that happened.

Benny

> put_lseg: lseg ce417e40 ref 3 valid 1
> NFS:    34 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> pnfs_writepages End (trypnfs:0)
> filelayout_write_call_done new off 49152 orig offset 49152
> pnfs_writeback_done: Begin (status -10008)
> put_lseg: lseg ce417e40 ref 2 valid 1
> NFS:    35 nfs_writeback_done (status -10008 count 3035)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> nfs4_renew_state: start
> nfs4_renew_state: failed to call renewd. Reason: lease not expired
> nfs4_renew_state: requeueing work. Lease period = 56
> nfs4_renew_state: done
> nfs4_renew_state: start
> nfs4_renew_state: failed to call renewd. Reason: lease not expired
> nfs4_renew_state: requeueing work. Lease period = 56
> nfs4_renew_state: done
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=2 slotid=0 max_slotid=3
> cache_this=1
> NFS:    29 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677247:2:2:0 seqid=2 slotid=0 max_slotid=2
> cache_this=1
> NFS:    30 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=2 slotid=1 max_slotid=3
> cache_this=1
> NFS:    31 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677247:2:2:0 seqid=2 slotid=1 max_slotid=2
> cache_this=1
> NFS:    32 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=2 slotid=2 max_slotid=3
> cache_this=1
> NFS:    33 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677247:2:2:0 seqid=2 slotid=2 max_slotid=2
> cache_this=1
> NFS:    34 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=2 slotid=3 max_slotid=3
> cache_this=1
> NFS:    35 nfs_writeback_done (status -10008 count 3035)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> nfs4_renew_state: start
> nfs4_renew_state: failed to call renewd. Reason: lease not expired
> nfs4_renew_state: requeueing work. Lease period = 37
> nfs4_renew_state: done
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=3 slotid=0 max_slotid=3
> cache_this=1
> NFS:    29 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677247:2:2:0 seqid=3 slotid=0 max_slotid=2
> cache_this=1
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=3 slotid=1 max_slotid=3
> cache_this=1
> NFS:    30 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> NFS:    31 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677247:2:2:0 seqid=3 slotid=1 max_slotid=2
> cache_this=1
> NFS:    32 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=3 slotid=2 max_slotid=3
> cache_this=1
> NFS:    33 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677247:2:2:0 seqid=3 slotid=2 max_slotid=2
> cache_this=1
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=3 slotid=3 max_slotid=3
> cache_this=1
> NFS:    34 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> NFS:    35 nfs_writeback_done (status -10008 count 3035)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=4 slotid=0 max_slotid=3
> cache_this=1
> NFS:    29 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677247:2:2:0 seqid=4 slotid=0 max_slotid=2
> cache_this=1
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=4 slotid=1 max_slotid=3
> cache_this=1
> NFS:    30 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> NFS:    31 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677247:2:2:0 seqid=4 slotid=1 max_slotid=2
> cache_this=1
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=4 slotid=2 max_slotid=3
> cache_this=1
> NFS:    32 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> NFS:    33 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> encode_compound: tag=
> encode_sequence: sessionid=1287677253:2:2:0 seqid=4 slotid=3 max_slotid=3
> cache_this=1
> encode_compound: tag=
> encode_sequence: sessionid=1287677247:2:2:0 seqid=4 slotid=2 max_slotid=2
> cache_this=1
> NFS:    35 nfs_writeback_done (status -10008 count 3035)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> NFS:    34 nfs_writeback_done (status -10008 count 8192)
> pnfs4_write_done DS write
> <-- pnfs4_write_done status= -11
> I don't know why so many pnfs_write_done()  return -11 only for the first
> write. But after the first write, I write files again. This time the time of
> the operation is OK. Please tell me why this thing happen.
> 
