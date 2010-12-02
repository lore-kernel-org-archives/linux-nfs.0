Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:47993 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752938Ab0LBQKo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Dec 2010 11:10:44 -0500
Date: Thu, 2 Dec 2010 11:10:42 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 4/5] various minor cleanups
Message-ID: <20101202161042.GA15055@merit.edu>
References: <cover.1291142529.git.rees@umich.edu>
 <55dae19c431eeee6d4fabf18550fdf976646a9a5.1291142529.git.rees@umich.edu>
 <4CF7A64D.8040802@panasas.com>
 <4CF7A8F9.8010902@panasas.com>
 <20101202144126.GA14604@merit.edu>
 <4CF7B086.6000403@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CF7B086.6000403@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

  Why can't it always dump the signature in hex, even if it happens to be ASCII?

I need it in ascii because that's how all my other tools print it out.  When
I mis-place a disk, I start by looking at it on the server:

[nasadmin@emc-0 ~]$ nas_disk -l
id   inuse  sizeMB    storageID-devID   type  name          servers
1     y      11263  APM00064403224-0000 CLSTD root_disk     1,2
2     y      11263  APM00064403224-0001 CLSTD root_ldisk    1,2
3     y       2047  APM00064403224-0002 CLSTD d3            1,2
4     y       2047  APM00064403224-0003 CLSTD d4            1,2
5     y       2047  APM00064403224-0004 CLSTD d5            1,2
6     y      32767  APM00064403224-0005 CLSTD d6            1,2
7     n     451387  APM00064403224-0010 CLSTD d7            1,2
8     y     451387  APM00064403224-0011 CLSTD d8            1,2

Then on the client:

pdsi7# mpfsinq
Celerra signature        vendor   product_id        device serial number or pathinfo
APM000644032240000-0008  DGC      RAID 5            60:06:01:60:80:40:1a:00:be:91:96:89:d5:26:dd:11
   path = /dev/sdh               Active  SP-b0  /dev/sg7              
   path = /dev/sdg               Passive SP-a0  /dev/sg6              
APM000644032240000-0007  DGC      RAID 5            60:06:01:60:55:d1:19:00:1e:12:0e:87:d5:26:dd:11
   path = /dev/sde               Active  SP-a0  /dev/sg4              
   path = /dev/sdf               Passive SP-b0  /dev/sg5              

And finally in the blkmapd log:

blkmapd: process_deviceinfo: 28 vols
blkmapd: decode_blk_volume: bv_type 0
blkmapd: decode_blk_signature: si_comps[0]: bs_length 4, bs_string 0x7
blkmapd: decode_blk_signature: si_comps[1]: bs_length 32, bs_string APM000644032240000
blkmapd: read_cmp_blk_sig: /dev/sde sig 0x7 at 473313851392
blkmapd: read_cmp_blk_sig: /dev/sde sig APM000644032240000 at 473313851492
blkmapd: decode_blk_volume: bv_type 1
blkmapd: decode_blk_volume: bv_type 0
blkmapd: decode_blk_signature: si_comps[0]: bs_length 4, bs_string 0x8
blkmapd: decode_blk_signature: si_comps[1]: bs_length 32, bs_string APM000644032240000
blkmapd: read_cmp_blk_sig: /dev/sdh sig 0x8 at 473313851392
blkmapd: read_cmp_blk_sig: /dev/sdh sig APM000644032240000 at 473313851492
