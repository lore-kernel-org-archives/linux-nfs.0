Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:1265 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754476AbbESNnV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2015 09:43:21 -0400
Message-ID: <555B3DEE.1000900@fb.com>
Date: Tue, 19 May 2015 09:43:10 -0400
From: Chris Mason <clm@fb.com>
MIME-Version: 1.0
To: Govindarajulu Varadarajan <_govind@gmx.com>, <linux-btrfs@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
CC: <jbacik@fb.com>, <dsterba@suse.cz>
Subject: Re: btrfs: kernel BUG at mm/page-writeback.c:2286!
References: <alpine.LNX.2.03.1505191317300.21108@ws.cisco>
In-Reply-To: <alpine.LNX.2.03.1505191317300.21108@ws.cisco>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/19/2015 03:55 AM, Govindarajulu Varadarajan wrote:
> Hi all
> 
> I am seeing the following crash on my btrfs filesystem with nfs export.
> If I disable the nfs share and reboot, I do not hit the crash. Look like
> the crash happens on btrfs with nfs export.
> 
> Is this a known issue? Has anyone else faced this? Let me know if you
> need more
> information.
> 
> Thanks
> 
> mm/page-writeback.c:2286:
> int clear_page_dirty_for_io(struct page *page) {
>         struct address_space *mapping = page_mapping(page);
> 
> 2286--->BUG_ON(!PageLocked(page));
> 
> [  166.769868] BTRFS info (device sdf): no csum found for inode 1154
> start 43192320
> [  166.774334] BTRFS info (device sdf): csum failed ino 1154 extent
> 4434247680 csum 1388825687 wanted 0 mirror 0


Josef and I both missed this the first time you pasted it, but the
unlocked page is almost certainly related to this csum error.  While
we're looking at things can you please scrub?


-chris

