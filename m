Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p3plsmtpa08-07.prod.phx3.secureserver.net ([173.201.193.108]:36860
	"EHLO p3plsmtpa08-07.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932087Ab3DYUUZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Apr 2013 16:20:25 -0400
Message-ID: <51798E97.1000200@talpey.com>
Date: Thu, 25 Apr 2013 16:14:15 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Phil Pishioneri <pgp@psu.edu>
CC: Wendy Cheng <s.wendy.cheng@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Yan Burman <yanb@mellanox.com>, "Atchley, Scott" <atchleyes@ornl.gov>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: NFS over RDMA benchmark
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com> <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com> <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov> <CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com> <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com> <20130423210607.GJ3676@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com> <20130424150540.GB20275@fieldses.org> <20130424152631.GC20275@fieldses.org> <CABgxfbHShU7aEttJ35vdAjXduPFFj8+E4=5LZqOgh4e=5bax5Q@mail.gmail.com> <CABgxfbHpNgQyEjd2OVNMgJoLpt_VyLiOL5hMCLwotMd5kincwg@mail.gmail.com> <517823E0.4000402@talpey.com> <CABgxfbHePAyq6AH9TFKZKUmwEHOupuYUnfc1W99HAuDkYddUqQ@mail.gmail.com> <51797D8D.1080302@psu.edu>
In-Reply-To: <51797D8D.1080302@psu.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/25/2013 3:01 PM, Phil Pishioneri wrote:
> On 4/25/13 1:18 PM, Wendy Cheng wrote:
>> On Wed, Apr 24, 2013 at 11:26 AM, Tom Talpey <tom@talpey.com> wrote:
>>> 1)
>>>
>>> The client slot count is not hard-coded, it can easily be changed by
>>> writing a value to /proc and initiating a new mount. But I doubt that
>>> increasing the slot table will improve performance much, unless this is
>>> a small-random-read, and spindle-limited workload.
>> It was a shot in the dark :)  .. as our test bed has not been setup
>> yet .However, since I'll be working on (very) slow clients, increasing
>> this buffer is still interesting (to me). I don't see where it is
>> controlled by a /proc value (?) - but that is not a concern at this
>> moment as /proc entry is easy to add. More questions on the server
>> though (see below) ...
>
> Might there be confusion between the RDMA slot table and the TCP/UDP
> ones (which have proc entries under /proc/sys/sunrpc)?
>

No, the xprtrdma.ko creates similar slot table controls when it loads.
See the names below, prefixed with "rdma":

> tmt@Home:~$ ls /proc/sys/sunrpc
> max_resvport  nfsd_debug  nlm_debug  tcp_fin_timeout             tcp_slot_table_entries  udp_slot_table_entries
> min_resvport  nfs_debug   rpc_debug  tcp_max_slot_table_entries  transports
> tmt@Home:~$ sudo insmod xprtrdma
> tmt@Home:~$ ls /proc/sys/sunrpc
> max_resvport  nlm_debug                  rdma_memreg_strategy     tcp_fin_timeout             udp_slot_table_entries
> min_resvport  rdma_inline_write_padding  rdma_pad_optimize        tcp_max_slot_table_entries
> nfsd_debug    rdma_max_inline_read       rdma_slot_table_entries  tcp_slot_table_entries
> nfs_debug     rdma_max_inline_write      rpc_debug                transports
> tmt@Home:~$


