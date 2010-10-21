Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:64903 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302Ab0JURIF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 13:08:05 -0400
Received: by iwn7 with SMTP id 7so3849756iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 21 Oct 2010 10:08:03 -0700 (PDT)
In-Reply-To: <4CC06EE8.7010705@panasas.com>
References: <AANLkTi=XSSM5+wmCrVzQrZF8rA81OLqDO_dMzUqwHc7g@mail.gmail.com>
	<4CC06EE8.7010705@panasas.com>
Date: Thu, 21 Oct 2010 13:08:02 -0400
Message-ID: <AANLkTim6aBaQ=yj0UYhiXSFzHh37V756EGurw1JorKPX@mail.gmail.com>
Subject: Re: [pnfs] pnfs first write has very long delay
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: quanli gui <gqlxj1987@gmail.com>, linux-pnfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The first I/O to a data server includes:

1) setting up the session EXCHANGE_ID, CREATE_SESSION
2) the first time a Linux server (including a data server ) sees a
file handle, it does an upcall to mountd to import the share
information into the kernel. This is one cause of the NFS4_ERR_DELAY.

The write status of -11 is EAGAIN which is the response to NFS4_ERR_DELAY

-->Andy

On Thu, Oct 21, 2010 at 12:48 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> On 2010-10-21 14:03, quanli gui wrote:
>> When pnfs is mount on the client, I write a file to the mount dir by the
>> first time. It must wait a very long time until the pnfs complete the write.
>> When the operation waited, I dmesg the operation information. Find that
>> NFS:     0 initiated write call (req 0:13/200809, 3035 bytes @ offset 49152)
>> --> nfs4_setup_sequence clp c450a800 session c450ac00 sr_slotid 128
>> --> nfs41_setup_sequence
>> --> nfs4_find_slot used_slots=0007 highest_used=2 max_slots=16
>> <-- nfs4_find_slot used_slots=000f highest_used=3 slotid=3
>> <-- nfs41_setup_sequence slotid=3 seqid=1
>> <-- nfs4_setup_sequence status=0
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=1 slotid=3 max_slotid=3
>> cache_this=1
>> filelayout_write_call_done new off 40960 orig offset 40960
>> pnfs_writeback_done: Begin (status -10008)
>
> What kind of DS are you using?
> The 10008 error means that the DS returned NFS4ERR_DELAY
> so we need to understand why that happened.
>
> Benny
>
>> put_lseg: lseg ce417e40 ref 3 valid 1
>> NFS:    34 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> pnfs_writepages End (trypnfs:0)
>> filelayout_write_call_done new off 49152 orig offset 49152
>> pnfs_writeback_done: Begin (status -10008)
>> put_lseg: lseg ce417e40 ref 2 valid 1
>> NFS:    35 nfs_writeback_done (status -10008 count 3035)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> nfs4_renew_state: start
>> nfs4_renew_state: failed to call renewd. Reason: lease not expired
>> nfs4_renew_state: requeueing work. Lease period = 56
>> nfs4_renew_state: done
>> nfs4_renew_state: start
>> nfs4_renew_state: failed to call renewd. Reason: lease not expired
>> nfs4_renew_state: requeueing work. Lease period = 56
>> nfs4_renew_state: done
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=2 slotid=0 max_slotid=3
>> cache_this=1
>> NFS:    29 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677247:2:2:0 seqid=2 slotid=0 max_slotid=2
>> cache_this=1
>> NFS:    30 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=2 slotid=1 max_slotid=3
>> cache_this=1
>> NFS:    31 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677247:2:2:0 seqid=2 slotid=1 max_slotid=2
>> cache_this=1
>> NFS:    32 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=2 slotid=2 max_slotid=3
>> cache_this=1
>> NFS:    33 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677247:2:2:0 seqid=2 slotid=2 max_slotid=2
>> cache_this=1
>> NFS:    34 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=2 slotid=3 max_slotid=3
>> cache_this=1
>> NFS:    35 nfs_writeback_done (status -10008 count 3035)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> nfs4_renew_state: start
>> nfs4_renew_state: failed to call renewd. Reason: lease not expired
>> nfs4_renew_state: requeueing work. Lease period = 37
>> nfs4_renew_state: done
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=3 slotid=0 max_slotid=3
>> cache_this=1
>> NFS:    29 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677247:2:2:0 seqid=3 slotid=0 max_slotid=2
>> cache_this=1
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=3 slotid=1 max_slotid=3
>> cache_this=1
>> NFS:    30 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> NFS:    31 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677247:2:2:0 seqid=3 slotid=1 max_slotid=2
>> cache_this=1
>> NFS:    32 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=3 slotid=2 max_slotid=3
>> cache_this=1
>> NFS:    33 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677247:2:2:0 seqid=3 slotid=2 max_slotid=2
>> cache_this=1
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=3 slotid=3 max_slotid=3
>> cache_this=1
>> NFS:    34 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> NFS:    35 nfs_writeback_done (status -10008 count 3035)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=4 slotid=0 max_slotid=3
>> cache_this=1
>> NFS:    29 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677247:2:2:0 seqid=4 slotid=0 max_slotid=2
>> cache_this=1
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=4 slotid=1 max_slotid=3
>> cache_this=1
>> NFS:    30 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> NFS:    31 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677247:2:2:0 seqid=4 slotid=1 max_slotid=2
>> cache_this=1
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=4 slotid=2 max_slotid=3
>> cache_this=1
>> NFS:    32 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> NFS:    33 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677253:2:2:0 seqid=4 slotid=3 max_slotid=3
>> cache_this=1
>> encode_compound: tag=
>> encode_sequence: sessionid=1287677247:2:2:0 seqid=4 slotid=2 max_slotid=2
>> cache_this=1
>> NFS:    35 nfs_writeback_done (status -10008 count 3035)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> NFS:    34 nfs_writeback_done (status -10008 count 8192)
>> pnfs4_write_done DS write
>> <-- pnfs4_write_done status= -11
>> I don't know why so many pnfs_write_done()  return -11 only for the first
>> write. But after the first write, I write files again. This time the time of
>> the operation is OK. Please tell me why this thing happen.
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
