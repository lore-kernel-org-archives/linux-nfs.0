Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p3plsmtpa06-09.prod.phx3.secureserver.net ([173.201.192.110]:53435
	"EHLO p3plsmtpa06-09.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755963Ab3DXSdB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2013 14:33:01 -0400
Message-ID: <517823E0.4000402@talpey.com>
Date: Wed, 24 Apr 2013 14:26:40 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Wendy Cheng <s.wendy.cheng@gmail.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Yan Burman <yanb@mellanox.com>,
        "Atchley, Scott" <atchleyes@ornl.gov>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: NFS over RDMA benchmark
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com> <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com> <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov> <CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com> <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com> <20130423210607.GJ3676@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com> <20130424150540.GB20275@fieldses.org> <20130424152631.GC20275@fieldses.org> <CABgxfbHShU7aEttJ35vdAjXduPFFj8+E4=5LZqOgh4e=5bax5Q@mail.gmail.com> <CABgxfbHpNgQyEjd2OVNMgJoLpt_VyLiOL5hMCLwotMd5kincwg@mail.gmail.com>
In-Reply-To: <CABgxfbHpNgQyEjd2OVNMgJoLpt_VyLiOL5hMCLwotMd5kincwg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/24/2013 2:04 PM, Wendy Cheng wrote:
> On Wed, Apr 24, 2013 at 9:27 AM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
>> On Wed, Apr 24, 2013 at 8:26 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> On Wed, Apr 24, 2013 at 11:05:40AM -0400, J. Bruce Fields wrote:
>>>> On Wed, Apr 24, 2013 at 12:35:03PM +0000, Yan Burman wrote:
>>>>>
>>>>>
>>>>>
>>>>> Perf top for the CPU with high tasklet count gives:
>>>>>
>>>>>               samples  pcnt         RIP        function                    DSO
>>>>>               _______ _____ ________________ ___________________________ ___________________________________________________________________
>>>>>
>>>>>               2787.00 24.1% ffffffff81062a00 mutex_spin_on_owner         /root/vmlinux
>>>>
>>>> I guess that means lots of contention on some mutex?  If only we knew
>>>> which one.... perf should also be able to collect stack statistics, I
>>>> forget how.
>>>
>>> Googling around....  I think we want:
>>>
>>>          perf record -a --call-graph
>>>          (give it a chance to collect some samples, then ^C)
>>>          perf report --call-graph --stdio
>>>
>>
>> I have not looked at NFS RDMA (and 3.x kernel) source yet. But see
>> that "rb_prev" up in the #7 spot ? Do we have Red Black tree somewhere
>> in the paths ? Trees like that requires extensive lockings.
>>
>
> So I did a quick read on sunrpc/xprtrdma source (based on OFA 1.5.4.1
> tar ball) ... Here is a random thought (not related to the rb tree
> comment).....
>
> The inflight packet count seems to be controlled by
> xprt_rdma_slot_table_entries that is currently hard-coded as
> RPCRDMA_DEF_SLOT_TABLE (32) (?).  I'm wondering whether it could help
> with the bandwidth number if we pump it up, say 64 instead ? Not sure
> whether FMR pool size needs to get adjusted accordingly though.

1)

The client slot count is not hard-coded, it can easily be changed by
writing a value to /proc and initiating a new mount. But I doubt that
increasing the slot table will improve performance much, unless this is
a small-random-read, and spindle-limited workload.

2)

The observation appears to be that the bandwidth is server CPU limited.
Increasing the load offered by the client probably won't move the needle,
until that's addressed.


>
> In short, if anyone has benchmark setup handy, bumping up the slot
> table size as the following might be interesting:
>
> --- ofa_kernel-1.5.4.1.orig/include/linux/sunrpc/xprtrdma.h
> 2013-03-21 09:19:36.233006570 -0700
> +++ ofa_kernel-1.5.4.1/include/linux/sunrpc/xprtrdma.h  2013-04-24
> 10:52:20.934781304 -0700
> @@ -59,7 +59,7 @@
>    * a single chunk type per message is supported currently.
>    */
>   #define RPCRDMA_MIN_SLOT_TABLE (2U)
> -#define RPCRDMA_DEF_SLOT_TABLE (32U)
> +#define RPCRDMA_DEF_SLOT_TABLE (64U)
>   #define RPCRDMA_MAX_SLOT_TABLE (256U)
>
>   #define RPCRDMA_DEF_INLINE  (1024)     /* default inline max */
>
> -- Wendy
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
