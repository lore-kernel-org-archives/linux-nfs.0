Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailedge.sta.samsung.com ([63.166.115.4]:41807 "EHLO
	cuda1.sta.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086Ab2AQQiH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jan 2012 11:38:07 -0500
From: Fan Zhang <fzhang@sta.samsung.com>
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Tue, 17 Jan 2012 10:17:22 -0600
Subject: Bypass encrypt and decrypt data in dm-crypt
Message-ID: <2DFF60F1B02D0940A28208B18A97A53C786EDE6549@staex7mb2.telecom.sna.samsung.com>
References: <1326816029-13913-1-git-send-email-bfields@redhat.com>
 <1326816029-13913-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1326816029-13913-3-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All:


We are using dm-crypt for Android device encryption.  However, we need reserve some sectors in block device for status and integration check and do not want to encrypt/decrypt some sectors when using dm-crypt.
 
So in crypt_convert_block()
 
When 
offset sector of ctx +  sector number of bio_in  is the range of bypass sector list.
 
 
instead call 
if (bio_data_dir(ctx->bio_in) == WRITE)
 r = crypt_copy_write_data(bv_in, bv_out, offset, 1 << SECTOR_SHIFT);
else
 r = crypt_copy_read_data(bv_in, bv_out, offset, 1 << SECTOR_SHIFT);
 
I want to call another function to copy data of a sector from 
ctx->bio_in to 
ctx->bio_out directly.
 
 
I tried the following implementation 
 
struct bio_vec *bv_in = bio_iovec_idx(ctx->bio_in, ctx->idx_in);
struct bio_vec *bv_out = bio_iovec_idx(ctx->bio_out, ctx->idx_out);
struct page * page_in = bv_in->bv_page;
struct page * page_out = bv_out->bv_page;
 
void * addr1 = kmap_atomic(page_in, KM_USER0);
void * addr2 = kmap_atomic(page_out, KM_USER1);
 
unsigned int offset = ctx->offset_in;
 
memcpy(addr2 + offset, addr1 + offset, 1 << SECTOR_SHIFT);
 
kunmap_atomic(addr2, KM_USER1);
kunmap_atomic(addr1, KM_USER0);
 
but above implementation does not work.
 
Could you give me a kint to reslove this issue?
 
 
Thanks
 
Fan
 
 
 
 
