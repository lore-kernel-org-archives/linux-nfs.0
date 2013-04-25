Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f177.google.com ([209.85.210.177]:54476 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757807Ab3DYRSB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2013 13:18:01 -0400
MIME-Version: 1.0
In-Reply-To: <517823E0.4000402@talpey.com>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
	<CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
	<62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov>
	<CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
	<20130423210607.GJ3676@fieldses.org>
	<0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com>
	<20130424150540.GB20275@fieldses.org>
	<20130424152631.GC20275@fieldses.org>
	<CABgxfbHShU7aEttJ35vdAjXduPFFj8+E4=5LZqOgh4e=5bax5Q@mail.gmail.com>
	<CABgxfbHpNgQyEjd2OVNMgJoLpt_VyLiOL5hMCLwotMd5kincwg@mail.gmail.com>
	<517823E0.4000402@talpey.com>
Date: Thu, 25 Apr 2013 10:18:00 -0700
Message-ID: <CABgxfbHePAyq6AH9TFKZKUmwEHOupuYUnfc1W99HAuDkYddUqQ@mail.gmail.com>
Subject: Re: NFS over RDMA benchmark
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Tom Talpey <tom@talpey.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Yan Burman <yanb@mellanox.com>,
        "Atchley, Scott" <atchleyes@ornl.gov>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 24, 2013 at 11:26 AM, Tom Talpey <tom@talpey.com> wrote:
>> On Wed, Apr 24, 2013 at 9:27 AM, Wendy Cheng <s.wendy.cheng@gmail.com>
>> wrote:
>>>
>> So I did a quick read on sunrpc/xprtrdma source (based on OFA 1.5.4.1
>> tar ball) ... Here is a random thought (not related to the rb tree
>> comment).....
>>
>> The inflight packet count seems to be controlled by
>> xprt_rdma_slot_table_entries that is currently hard-coded as
>> RPCRDMA_DEF_SLOT_TABLE (32) (?).  I'm wondering whether it could help
>> with the bandwidth number if we pump it up, say 64 instead ? Not sure
>> whether FMR pool size needs to get adjusted accordingly though.
>
> 1)
>
> The client slot count is not hard-coded, it can easily be changed by
> writing a value to /proc and initiating a new mount. But I doubt that
> increasing the slot table will improve performance much, unless this is
> a small-random-read, and spindle-limited workload.

Hi Tom !

It was a shot in the dark :)  .. as our test bed has not been setup
yet .However, since I'll be working on (very) slow clients, increasing
this buffer is still interesting (to me). I don't see where it is
controlled by a /proc value (?) - but that is not a concern at this
moment as /proc entry is easy to add. More questions on the server
though (see below) ...

>
> 2)
>
> The observation appears to be that the bandwidth is server CPU limited.
> Increasing the load offered by the client probably won't move the needle,
> until that's addressed.
>

Could you give more hints on which part of the path is CPU limited ?
Is there a known Linux-based filesystem that is reasonbly tuned for
NFS-RDMA ? Any specific filesystem features would work well with
NFS-RDMA ? I'm wondering when disk+FS are added into the
configuration, how much advantages would NFS-RDMA get when compared
with a plain TCP/IP, say IPOIB on CM , transport ?

-- Wendy
