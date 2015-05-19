Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:63226 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754524AbbESOoz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2015 10:44:55 -0400
Message-ID: <555B4C4E.2020403@fb.com>
Date: Tue, 19 May 2015 10:44:30 -0400
From: Chris Mason <clm@fb.com>
MIME-Version: 1.0
To: Piotr Szymaniak <szarpaj@grubelek.pl>
CC: Govindarajulu Varadarajan <_govind@gmx.com>, <linux-btrfs@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <jbacik@fb.com>, <dsterba@suse.cz>
Subject: Re: btrfs: kernel BUG at mm/page-writeback.c:2286!
References: <alpine.LNX.2.03.1505191317300.21108@ws.cisco> <555B3DEE.1000900@fb.com> <20150519135416.GO2539@wloczykij>
In-Reply-To: <20150519135416.GO2539@wloczykij>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/19/2015 09:54 AM, Piotr Szymaniak wrote:
> On Tue, May 19, 2015 at 09:43:10AM -0400, Chris Mason wrote:
>> On 05/19/2015 03:55 AM, Govindarajulu Varadarajan wrote:
>>> 2286--->BUG_ON(!PageLocked(page));
>>>
>>> [  166.769868] BTRFS info (device sdf): no csum found for inode 1154
>>> start 43192320
>>> [  166.774334] BTRFS info (device sdf): csum failed ino 1154 extent
>>> 4434247680 csum 1388825687 wanted 0 mirror 0
>>
>>
>> Josef and I both missed this the first time you pasted it, but the
>> unlocked page is almost certainly related to this csum error.  While
>> we're looking at things can you please scrub?

Josef and I just read through all of this, and I'm not finding a way to
connect the crc error to the BUG_ON.  Do all kernels crash like this, or
was it just 4.1-rc?

-chris


