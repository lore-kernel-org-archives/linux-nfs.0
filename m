Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:42975 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757948Ab2HJJUT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 05:20:19 -0400
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="utf-8"
Date: Fri, 10 Aug 2012 11:20:16 +0200
From: "Johannes Schild" <JSchild@gmx.de>
In-Reply-To: <CA+a=Yy6C-d82MR6Lun4sRcJ0euBBpf0Ra3cHDnQ8eKENi5eU2Q@mail.gmail.com>
Message-ID: <20120810092016.177360@gmx.net>
MIME-Version: 1.0
References: <20120808155829.177400@gmx.net> <20120808163916.GA24539@umich.edu>
 <20120808182622.177380@gmx.net> <20120809084236.177380@gmx.net>
 <5DFC6BE3BA248842867E85C73BF94B050B17B698CF@MX41A.corp.emc.com>
 <20120809152744.149360@gmx.net>
 <CA+a=Yy7rH7kFKJvS3eOae+Mb0C1p+N01h+Zqz7jVzGE+HXHt9g@mail.gmail.com>
 <20120810074818.119500@gmx.net>
 <CA+a=Yy6C-d82MR6Lun4sRcJ0euBBpf0Ra3cHDnQ8eKENi5eU2Q@mail.gmail.com>
Subject: Re: RE: Blocklayout
To: Peng Tao <tao.peng@emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tao,

> > [59260.324598] encoding getdevicelist!
> > [59260.324600] decode_getdevicelist: num_dev 1
> > [59260.324601] nfs41_sequence_done: Error 0 free the slot
> > [59260.324602] nfs4_free_slot: slotid 16 highest_used_slotid -1
> > [59260.324605] <-- _nfs4_getdevicelist status=0
> > [59260.324606] nfs4_proc_getdevicelist: err=0, num_devs=1
> > [59260.324607] bl_set_layoutdriver GETDEVICELIST numdevs=1, eof=1
> > [59260.324608] nfs4_blk_get_deviceinfo max_resp_sz 135168 max_pages 33
> > [59260.324629] nfs4_blk_get_deviceinfo: dev_id:
> The deviceid field returned by server is empty. That's why device
> discovery failed.

Is the deviceid the field where the signature, created with parted, should be stored?

 
> > [59260.324630] --> _nfs4_proc_getdeviceinfo
> > [59260.324632] --> nfs41_call_sync_prepare data->seq_server
> ffff88003c8d7800
> > [59260.324633] --> nfs4_setup_sequence clp ffff88003c733400 session
> ffff88003c733c00 sr_slot -1
> > [59260.324634] --> nfs41_setup_sequence
> > [59260.324635] --> nfs4_find_slot used_slots=0000
> highest_used=4294967295 max_slots=16
> > [59260.324636] <-- nfs4_find_slot used_slots=0001 highest_used=0
> slotid=0
> > [59260.324637] <-- nfs41_setup_sequence slotid=0 seqid=9
> > [59260.324638] <-- nfs4_setup_sequence status=0
> > [59260.324642] encode_sequence: sessionid=1344524732:4:4:0 seqid=9
> slotid=0 max_slotid=0 cache_this=0
> > [59260.333545] nfs41_sequence_done: Error 0 free the slot
> > [59260.333547] nfs4_free_slot: slotid 16 highest_used_slotid -1
> > [59260.333553] <-- _nfs4_proc_getdeviceinfo status=0
> > [59260.333555] nfs4_blk_get_deviceinfo getdevice info returns 0
> > [59260.333572] nfs4_blk_decode_device CREATING PIPEFS MESSAGE
> > [59260.333573] nfs4_blk_decode_device: deviceid: , mincount: 136
> Here shows the same error.
> 
> You may check server code to see if there is something wrong with
> getdevicelist proc handling.
>

I am not experienced enough to check this i think. Is there other server code than "ctl" (on the howto)?

> Cheers,
> Tao

Thanks

Johannes
