From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs]pnfs4_write_done problem
Date: Tue, 20 Jul 2010 17:36:49 +0300
Message-ID: <4C45B481.7090806@panasas.com>
References: <AANLkTinb6e40HcstWWP0mBQ33Q8sSM_s-s8mJM6Zoggj@mail.gmail.com>	<4C45557A.5020904@panasas.com> <AANLkTim2BKq6e8P6h6PKaGbuov_9jKzDNyd0cmXveYWF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-pnfs <linux-nfs@vger.kernel.org>,
	"Sager, Mike" <Mike.Sager@netapp.com>
To: quanli gui <gqlxj1987@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:23728 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758234Ab0GTOgx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 10:36:53 -0400
In-Reply-To: <AANLkTim2BKq6e8P6h6PKaGbuov_9jKzDNyd0cmXveYWF-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 20, 2010, 13:38 +0300, quanli gui <gqlxj1987@gmail.com> wrote:
> Debug information in the Client:
> <4>pnfs_writepages: Writing ino:1130497 16@0
> <4>get_lock_alloc_layout Begin
> <4>get_lock_alloc_layout Return caef842c
> <4>pnfs_has_layout:Begin
> <4>pnfs_has_layout:Return lseg ce196060 take_ref 1 ref 2 valid 1
> <4>pnfs_update_layout: Using cached lseg ce196060 for 16@0 iomode 2)
> <4>pnfs_update_layout end (err:0) state 0x0 lseg ce196060
> <4>pnfs_writepages: Calling layout driver (how 0) write with 1 pages
> <4>--> filelayout_write_pagelist ino 1130497 nr_pages 1 pgbase 0 req
> 16@0 sync 0
> <4>filelayout_write_pagelist ino 1130497 16@0 DS:c0a80005:2049
> 192.168.0.5.8.1
> <4>--> pnfs4_proc_write_setup ds_nfs_client c5d90000
> <4>--> nfs4_setup_sequence clp c5d90000 session c5d90600 sr_slotid 128
> <4>--> nfs41_setup_sequence
> <4>--> nfs4_find_slot used_slots=0000 highest_used=-1 max_slots=16
> <4><-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
> <4><-- nfs41_setup_sequence slotid=0 seqid=1
> <4><-- nfs4_setup_sequence status=0
> <4>pnfs_writeback_done: Begin (status -10008)

This seems to be the culprit.
The DS is returning NFS4ERR_DELAY.

This could be the server grace period.
Does this happen only right after the system start?

If you wait for 2 minutes after the server starts and then
run the test do you see this delay?

Benny

> <4>put_lseg: lseg ce196060 ref 2 valid 1
> <4>pnfs4_write_done DS write
> <4><-- pnfs4_write_done status= -11
> //wait long time
> <4>pnfs4_write_done DS write
> <4><-- pnfs4_write_done status= -11
> <4>pnfs4_write_done DS write
> <4><-- pnfs4_write_done status= -11
> <4>pnfs4_write_done DS write
> <4><-- pnfs4_write_done status= -11
> //pnfs4_write_done status wait long time
> <4>--> nfs4_setup_sequence clp c5da3c00 session ce185000 sr_slotid 128
> <4>--> nfs41_setup_sequence
> <4>--> nfs4_find_slot used_slots=0000 highest_used=-1 max_slots=16
> <4><-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0 
> <4><-- nfs41_setup_sequence slotid=0 seqid=20
> <4><-- nfs4_setup_sequence status=0
> <4>nfs4_free_slot: free_slotid 0 highest_used_slotid -1
> <4>nfs41_sequence_call_done rpc_cred cef74c80
> <4><-- nfs41_sequence_call_done
> <4>pnfs4_write_done DS write
> <4>pnfs_update_last_write: Wrote 16@0 bpos 0, epos: 15
> <4>pnfs_need_layoutcommit: has_layout=1 layoutcommit_ctx=(null) ctx=c5d95400
> <4>pnfs_need_layoutcommit: Set layoutcommit_ctx=c5d95400
> <4>nfs4_free_slot: free_slotid 0 highest_used_slotid -1
> <4>--> pnfs_update_layout_commit inode caef846c layout range: 0@0
> 
> The process should have no problem, because after this first write,
> other write only not wait long time. Thanks for giving me some answers.
> 
> 2010/7/20 Benny Halevy <bhalevy@panasas.com <mailto:bhalevy@panasas.com>>
> 
>     Gui, There could be many reasons for what you see
>     but you must provide more debug information otherwise
>     we'll just keep guessing.
> 
>     Thanks for reporting and helping to track this!
> 
>     Benny
> 
>     On Jul. 20, 2010, 10:05 +0300, quanli gui <gqlxj1987@gmail.com
>     <mailto:gqlxj1987@gmail.com>> wrote:
>     > When pnfs firstly write, the pnfs would stay at the function
>     > pnfs4_write_done(), and show that
>     > pnfs4_write_done DS write
>     > <-- pnfs4_write_done status=-11
>     > This two message would shows many times. At the same time, the
>     data not
>     > write completely to the DS. This write we would wait long time to
>     > complete. But after the first write, for other writes we don't have to
>     > wait, as the same as the fact. Why for the first write, we must
>     wait too
>     > long time? And staying at the function pnfs4_write_done() means what?
>     > Please give me some answers.
> 
> 
