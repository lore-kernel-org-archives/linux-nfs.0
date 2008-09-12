From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Fri, 12 Sep 2008 18:15:22 -0500
Message-ID: <48CAF80A.4010109@opengridcomputing.com>
References: <48B2D7F8.5020206@opengridcomputing.com> <20080826192711.GJ4380@fieldses.org> <48B567F5.2090605@opengridcomputing.com> <1220111261.31172.14.camel@localhost.localdomain> <20080831193037.GB14876@fieldses.org> <1220211842.31172.18.camel@localhost.localdomain> <48BAF643.4070808@opengridcomputing.com> <1220217505.31172.26.camel@localhost.localdomain> <48BC2466.2070806@opengridcomputing.com> <1221036015.24993.27.camel@zakaz.uk.xensource.com> <20080912224323.GN22126@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	John Ronciak <john.ronciak@gmail.com>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:6430 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756436AbYILXPY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Sep 2008 19:15:24 -0400
In-Reply-To: <20080912224323.GN22126@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Sep 10, 2008 at 09:40:15AM +0100, Ian Campbell wrote:
>   
>> On Mon, 2008-09-01 at 12:20 -0500, Tom Tucker wrote: 
>>     
>>> Ian Campbell wrote:
>>>       
>>>> On Sun, 2008-08-31 at 14:51 -0500, Tom Tucker wrote:
>>>>   
>>>>         
>>>>> Looks like you ran this on the client. Sorry, Ian, I should have been
>>>>> more specific. You need to modify the rpc_debug file on the server.
>>>>>     
>>>>>           
>>>> I tried this on the server but it's pretty crippling (the server is
>>>> quite weedy, 300MHz K3 or something).
>>>>
>>>> I'll leave it logging overnight since things should be pretty quiet (and
>>>> that's often when the problem occurs) but if there's a less aggressive
>>>> setting than 256 but which would still be useful I could leave it on
>>>> permanently until the problem happens.
>>>>
>>>>   
>>>>         
>>> Thanks Ian. Unfortunately, that's as fine grained as it gets. 256 
>>> (0x100) is the bit for transport logging.
>>>       
>> Still no repro with the debugging enabled I'm afraid.
>>
>> I'm wondering if the performance hit makes it unlikely to trigger since
>> everything slows to a crawl. I haven't been able to leave it on 24/7
>> since it makes all the NFS clients nearly unusable but I've had it on
>> overnight and when there's no one around etc, which is when the hang
>> generally seems to occur.
>>     
>
> OK, thanks for the attempt.  We should figure out how to tone down those
> dprintk's.
>
> I'll try to take a closer look at this, but I'm travelling starting
> tomorrow, and realistically may not find time to look at this for a
> couple weeks.  If someone else gets to it before me, great....
>
> --b.
>
>   
>> I forgot to re-enable it one evening and, perhaps inevitably, it crashed
>> overnight. I turned the debugging on and captured the following. It's
>> not much since syslog had given up for some reason, probably when the
>> disk filled up with logs. 192.168.1.5 is a non-problematic client so I
>> don't think the log will be useful since the problematic client
>> (192.168.1.4) isn't mentioned..
>>
>> Ian.
>>
>>     

Iain sadly yes. There's a thread stuck holding the BUSY bit or a thread 
failed to clear the bit properly
(maybe an error path). Data continues to arrives, but the transport 
never gets put back on the queue
because it's BUSY bit is set.  In other words, this is a different error 
than the one we've been chasing.

If I sent you a patch, could you rebuild the kernel and give it a whirl? 
Also, can you give me a
kernel.org relative commit-id or tag for the kernel that you're using?

Thanks,
Tom

>> vc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.094587] svc: TCP record, 140 bytes
>> [4009900.098604] svc: socket ee5fd600 recvfrom(e996b08c, 3956) = 140
>> [4009900.102587] svc: TCP complete record (140 bytes)
>> [4009900.106592] svc: transport ee5fd600 put into queue
>> [4009900.110613] svc: got len=140
>> [4009900.114645] svc: transport ee5fd600 busy, not enqueued
>> [4009900.118752] svc: socket ee5fd600 sendto([dfbb0000 232... ], 232) = 232 (addr 192.168.1.5, port=910)
>> [4009900.122636] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009900.126588] svc: transport ee5fd600 busy, not enqueued
>> [4009900.130601] svc: transport ee5fd600 busy, not enqueued
>> [4009900.134593] svc: server eefc4000 waiting for data (to = 900000)
>> [4009900.162711] svc: transport ee5fd600 dequeued, inuse=1
>> [4009900.166598] svc: server eef4a000, pool 0, transport ee5fd600, inuse=2
>> [4009900.170594] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009900.174611] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.178592] svc: TCP record, 136 bytes
>> [4009900.182606] svc: socket ee5fd600 recvfrom(e975a088, 3960) = 136
>> [4009900.186592] svc: TCP complete record (136 bytes)
>> [4009900.190599] svc: transport ee5fd600 put into queue
>> [4009900.194605] svc: got len=136
>> [4009900.198632] svc: transport ee5fd600 busy, not enqueued
>> [4009900.202717] svc: socket ee5fd600 sendto([d6464000 124... ], 124) = 124 (addr 192.168.1.5, port=910)
>> [4009900.206664] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009900.210594] svc: transport ee5fd600 busy, not enqueued
>> [4009900.214611] svc: transport ee5fd600 busy, not enqueued
>> [4009900.218599] svc: server eef4a000 waiting for data (to = 900000)
>> [4009900.254640] svc: transport ee5fd600 dequeued, inuse=1
>> [4009900.258603] svc: server ee978000, pool 0, transport ee5fd600, inuse=2
>> [4009900.262601] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009900.266625] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.270598] svc: TCP record, 128 bytes
>> [4009900.274618] svc: socket ee5fd600 recvfrom(dd54d080, 3968) = 128
>> [4009900.278598] svc: TCP complete record (128 bytes)
>> [4009900.282605] svc: transport ee5fd600 put into queue
>> [4009900.286611] svc: got len=128
>> [4009900.290642] svc: transport ee5fd600 busy, not enqueued
>> [4009900.294788] svc: socket ee5fd600 sendto([efb5c000 116... ], 116) = 116 (addr 192.168.1.5, port=910)
>> [4009900.298707] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009900.302600] svc: transport ee5fd600 busy, not enqueued
>> [4009900.306622] svc: transport ee5fd600 busy, not enqueued
>> [4009900.310604] svc: server ee978000 waiting for data (to = 900000)
>> [4009900.346682] svc: transport ee5fd600 dequeued, inuse=1
>> [4009900.350609] svc: server ee8fe000, pool 0, transport ee5fd600, inuse=2
>> [4009900.354606] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009900.358626] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.362603] svc: TCP record, 148 bytes
>> [4009900.366622] svc: socket ee5fd600 recvfrom(eec92094, 3948) = 148
>> [4009900.370604] svc: TCP complete record (148 bytes)
>> [4009900.374612] svc: transport ee5fd600 put into queue
>> [4009900.378610] svc: got len=148
>> [4009900.382652] svc: transport ee5fd600 busy, not enqueued
>> [4009900.386829] svc: socket ee5fd600 sendto([e98bf000 232... ], 232) = 232 (addr 192.168.1.5, port=910)
>> [4009900.390688] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009900.394606] svc: transport ee5fd600 busy, not enqueued
>> [4009900.398621] svc: transport ee5fd600 busy, not enqueued
>> [4009900.402611] svc: server ee8fe000 waiting for data (to = 900000)
>> [4009900.438683] svc: transport ee5fd600 dequeued, inuse=1
>> [4009900.442614] svc: server eef12000, pool 0, transport ee5fd600, inuse=2
>> [4009900.446612] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009900.450634] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.454609] svc: TCP record, 156 bytes
>> [4009900.458631] svc: socket ee5fd600 recvfrom(dd78509c, 3940) = 156
>> [4009900.462692] svc: TCP complete record (156 bytes)
>> [4009900.466693] svc: transport ee5fd600 put into queue
>> [4009900.470610] svc: got len=156
>> [4009900.474657] svc: transport ee5fd600 busy, not enqueued
>> [4009900.478801] svc: socket ee5fd600 sendto([ee92b000 232... ], 232) = 232 (addr 192.168.1.5, port=910)
>> [4009900.482696] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009900.486611] svc: transport ee5fd600 busy, not enqueued
>> [4009900.490630] svc: transport ee5fd600 busy, not enqueued
>> [4009900.494617] svc: server eef12000 waiting for data (to = 900000)
>> [4009900.522817] svc: transport ee5fd600 dequeued, inuse=1
>> [4009900.526622] svc: server ee9f2000, pool 0, transport ee5fd600, inuse=2
>> [4009900.530617] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009900.534639] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.538615] svc: TCP record, 124 bytes
>> [4009900.542632] svc: socket ee5fd600 recvfrom(e977007c, 3972) = 124
>> [4009900.546615] svc: TCP complete record (124 bytes)
>> [4009900.550621] svc: transport ee5fd600 put into queue
>> [4009900.554616] svc: got len=124
>> [4009900.558656] svc: transport ee5fd600 busy, not enqueued
>> [4009900.562766] svc: socket ee5fd600 sendto([dd5e1000 124... ], 124) = 124 (addr 192.168.1.5, port=910)
>> [4009900.566724] svc: transport ee5fd600 busy, not enqueued
>> [4009900.570622] svc: server ee9f2000 waiting for data (to = 900000)
>> [4009900.607202] svc: transport ee5fd600 dequeued, inuse=1
>> [4009900.610629] svc: server eeeb7000, pool 0, transport ee5fd600, inuse=2
>> [4009900.614623] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009900.618647] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.622619] svc: TCP record, 124 bytes
>> [4009900.626641] svc: socket ee5fd600 recvfrom(e971607c, 3972) = 124
>> [4009900.630620] svc: TCP complete record (124 bytes)
>> [4009900.634630] svc: transport ee5fd600 put into queue
>> [4009900.638621] svc: got len=124
>> [4009900.642661] svc: transport ee5fd600 busy, not enqueued
>> [4009900.646760] svc: socket ee5fd600 sendto([e95ee000 124... ], 124) = 124 (addr 192.168.1.5, port=910)
>> [4009900.650734] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009900.654622] svc: transport ee5fd600 busy, not enqueued
>> [4009900.658640] svc: transport ee5fd600 busy, not enqueued
>> [4009900.662626] svc: server eeeb7000 waiting for data (to = 900000)
>> [4009900.691707] svc: transport ee5fd600 dequeued, inuse=1
>> [4009900.694637] svc: server eef31000, pool 0, transport ee5fd600, inuse=2
>> [4009900.698628] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009900.702646] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.706625] svc: TCP record, 156 bytes
>> [4009900.710654] svc: socket ee5fd600 recvfrom(e99b009c, 3940) = 156
>> [4009900.714626] svc: TCP complete record (156 bytes)
>> [4009900.718632] svc: transport ee5fd600 put into queue
>> [4009900.722626] svc: got len=156
>> [4009900.725731] svc: transport ee5fd600 busy, not enqueued
>> [4009900.726797] svc: socket ee5fd600 sendto([e9bee000 232... ], 232) = 232 (addr 192.168.1.5, port=910)
>> [4009900.730717] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009900.734627] svc: transport ee5fd600 busy, not enqueued
>> [4009900.738646] svc: transport ee5fd600 busy, not enqueued
>> [4009900.742631] svc: server eef31000 waiting for data (to = 900000)
>> [4009900.778691] svc: transport ee5fd600 dequeued, inuse=1
>> [4009900.782635] svc: server eefc4000, pool 0, transport ee5fd600, inuse=2
>> [4009900.786633] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009900.790649] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.794631] svc: TCP record, 144 bytes
>> [4009900.798663] svc: socket ee5fd600 recvfrom(e996b090, 3952) = 144
>> [4009900.802632] svc: TCP complete record (144 bytes)
>> [4009900.806638] svc: transport ee5fd600 put into queue
>> [4009900.810632] svc: got len=144
>> [4009900.814675] svc: transport ee5fd600 busy, not enqueued
>> [4009900.818858] svc: socket ee5fd600 sendto([dfbb0000 232... ], 232) = 232 (addr 192.168.1.5, port=910)
>> [4009900.822707] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009900.826632] svc: transport ee5fd600 busy, not enqueued
>> [4009900.830647] svc: transport ee5fd600 busy, not enqueued
>> [4009900.834638] svc: server eefc4000 waiting for data (to = 900000)
>> [4009900.862781] svc: transport ee5fd600 dequeued, inuse=1
>> [4009900.866647] svc: server eef4a000, pool 0, transport ee5fd600, inuse=2
>> [4009900.870644] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009900.874651] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.878636] svc: TCP record, 136 bytes
>> [4009900.882649] svc: socket ee5fd600 recvfrom(e975a088, 3960) = 136
>> [4009900.886636] svc: TCP complete record (136 bytes)
>> [4009900.890642] svc: transport ee5fd600 put into queue
>> [4009900.894654] svc: got len=136
>> [4009900.898678] svc: transport ee5fd600 busy, not enqueued
>> [4009900.902761] svc: socket ee5fd600 sendto([d6464000 124... ], 124) = 124 (addr 192.168.1.5, port=910)
>> [4009900.906714] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009900.910638] svc: transport ee5fd600 busy, not enqueued
>> [4009900.914654] svc: transport ee5fd600 busy, not enqueued
>> [4009900.918643] svc: server eef4a000 waiting for data (to = 900000)
>> [4009900.954826] svc: transport ee5fd600 dequeued, inuse=1
>> [4009900.958648] svc: server ee978000, pool 0, transport ee5fd600, inuse=2
>> [4009900.962645] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009900.966667] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009900.970642] svc: TCP record, 140 bytes
>> [4009900.974659] svc: socket ee5fd600 recvfrom(dd54d08c, 3956) = 140
>> [4009900.978652] svc: TCP complete record (140 bytes)
>> [4009900.982649] svc: transport ee5fd600 put into queue
>> [4009900.986642] svc: got len=140
>> [4009900.990686] svc: transport ee5fd600 busy, not enqueued
>> [4009900.994848] svc: socket ee5fd600 sendto([efb5c000 232... ], 232) = 232 (addr 192.168.1.5, port=910)
>> [4009900.998725] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009901.002644] svc: transport ee5fd600 busy, not enqueued
>> [4009901.006662] svc: transport ee5fd600 busy, not enqueued
>> [4009901.010648] svc: server ee978000 waiting for data (to = 900000)
>> [4009901.046694] svc: transport ee5fd600 dequeued, inuse=1
>> [4009901.050652] svc: server ee8fe000, pool 0, transport ee5fd600, inuse=2
>> [4009901.054650] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009901.058666] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009901.062647] svc: TCP record, 156 bytes
>> [4009901.066669] svc: socket ee5fd600 recvfrom(eec9209c, 3940) = 156
>> [4009901.070648] svc: TCP complete record (156 bytes)
>> [4009901.074655] svc: transport ee5fd600 put into queue
>> [4009901.078648] svc: got len=156
>> [4009901.082688] svc: transport ee5fd600 busy, not enqueued
>> [4009901.086844] svc: socket ee5fd600 sendto([e98bf000 232... ], 232) = 232 (addr 192.168.1.5, port=910)
>> [4009901.090750] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009901.094650] svc: transport ee5fd600 busy, not enqueued
>> [4009901.098671] svc: transport ee5fd600 busy, not enqueued
>> [4009901.102655] svc: server ee8fe000 waiting for data (to = 900000)
>> [4009901.138700] svc: transport ee5fd600 dequeued, inuse=1
>> [4009901.142658] svc: server ee9f2000, pool 0, transport ee5fd600, inuse=2
>> [4009901.146656] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009901.150678] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009901.154654] svc: TCP record, 124 bytes
>> [4009901.158671] svc: socket ee5fd600 recvfrom(e977007c, 3972) = 124
>> [4009901.162654] svc: TCP complete record (124 bytes)
>> [4009901.166659] svc: transport ee5fd600 put into queue
>> [4009901.170654] svc: got len=124
>> [4009901.174694] svc: transport ee5fd600 busy, not enqueued
>> [4009901.178811] svc: socket ee5fd600 sendto([dd67d000 124... ], 124) = 124 (addr 192.168.1.5, port=910)
>> [4009901.182741] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009901.186655] svc: transport ee5fd600 busy, not enqueued
>> [4009901.190673] svc: transport ee5fd600 busy, not enqueued
>> [4009901.194661] svc: server ee9f2000 waiting for data (to = 900000)
>> [4009901.222747] svc: transport ee5fd600 dequeued, inuse=1
>> [4009901.226690] svc: server eef12000, pool 0, transport ee5fd600, inuse=2
>> [4009901.230661] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009901.234677] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009901.238658] svc: TCP record, 152 bytes
>> [4009901.242673] svc: socket ee5fd600 recvfrom(dd785098, 3944) = 152
>> [4009901.246659] svc: TCP complete record (152 bytes)
>> [4009901.250664] svc: transport ee5fd600 put into queue
>> [4009901.254659] svc: got len=152
>> [4009901.258700] svc: transport ee5fd600 busy, not enqueued
>> [4009901.262809] svc: socket ee5fd600 sendto([ee92b000 232... ], 232) = 232 (addr 192.168.1.5, port=910)
>> [4009901.266734] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009901.270660] svc: transport ee5fd600 busy, not enqueued
>> [4009901.274677] svc: transport ee5fd600 busy, not enqueued
>> [4009901.278665] svc: server eef12000 waiting for data (to = 900000)
>> [4009901.314692] svc: transport ee5fd600 dequeued, inuse=1
>> [4009901.318668] svc: server eeeb7000, pool 0, transport ee5fd600, inuse=2
>> [4009901.322667] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009901.326682] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009901.330664] svc: TCP record, 156 bytes
>> [4009901.334681] svc: socket ee5fd600 recvfrom(e971609c, 3940) = 156
>> [4009901.338665] svc: TCP complete record (156 bytes)
>> [4009901.342672] svc: transport ee5fd600 put into queue
>> [4009901.346665] svc: got len=156
>> [4009901.350707] svc: transport ee5fd600 busy, not enqueued
>> [4009901.354849] svc: socket ee5fd600 sendto([e95ee000 232... ], 232) = 232 (addr 192.168.1.5, port=910)
>> [4009901.358747] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009901.362666] svc: transport ee5fd600 busy, not enqueued
>> [4009901.366683] svc: transport ee5fd600 busy, not enqueued
>> [4009901.370672] svc: server eeeb7000 waiting for data (to = 900000)
>> [4009901.406725] svc: transport ee5fd600 dequeued, inuse=1
>> [4009901.410674] svc: server eef31000, pool 0, transport ee5fd600, inuse=2
>> [4009901.414672] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009901.418691] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009901.422670] svc: TCP record, 136 bytes
>> [4009901.426690] svc: socket ee5fd600 recvfrom(e99b0088, 3960) = 136
>> [4009901.430671] svc: TCP complete record (136 bytes)
>> [4009901.434677] svc: transport ee5fd600 put into queue
>> [4009901.438684] svc: got len=136
>> [4009901.442710] svc: transport ee5fd600 busy, not enqueued
>> [4009901.446878] svc: socket ee5fd600 sendto([e9bee000 124... ], 124) = 124 (addr 192.168.1.5, port=910)
>> [4009901.450767] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009901.454672] svc: transport ee5fd600 busy, not enqueued
>> [4009901.458754] svc: transport ee5fd600 busy, not enqueued
>> [4009901.462690] svc: server eef31000 waiting for data (to = 900000)
>> [4009901.499151] svc: transport ee5fd600 dequeued, inuse=1
>> [4009901.502687] svc: server eefc4000, pool 0, transport ee5fd600, inuse=2
>> [4009901.506679] svc: tcp_recv ee5fd600 data 1 conn 0 close 0
>> [4009901.510698] svc: socket ee5fd600 recvfrom(ee5fd764, 0) = 4
>> [4009901.514675] svc: TCP record, 140 bytes
>> [4009901.518694] svc: socket ee5fd600 recvfrom(e996b08c, 3956) = 140
>> [4009901.522676] svc: TCP complete record (140 bytes)
>> [4009901.526683] svc: transport ee5fd600 put into queue
>> [4009901.530676] svc: got len=140
>> [4009901.534716] svc: transport ee5fd600 busy, not enqueued
>> [4009901.542824] svc: socket ee5fd600 sendto([dfbb0000 232... ], 232) = 232 (addr 192.168.1.5, port=910)
>> [4009901.546806] svc: socket c1888960 TCP data ready (svsk ee5fd600)
>> [4009901.550678] svc: transport ee5fd600 busy, not enqueued
>> [4009901.554700] svc: transport ee5fd600 busy, not enqueued
>> [4009901.558682] svc: server eefc4000 waiting for data (to = 900000)
>>
>>
>> -- 
>> Ian Campbell
>>
>> GIVE:	Support the helpless victims of computer error.
>>
>>     

