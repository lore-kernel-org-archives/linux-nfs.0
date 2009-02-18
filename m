Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:52539 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbZBRSOW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Feb 2009 13:14:22 -0500
Message-ID: <499C4FF4.6000006@vlnb.net>
Date: Wed, 18 Feb 2009 21:14:12 +0300
From: Vladislav Bolkhovitin <vst@vlnb.net>
To: Wu Fengguang <wfg@linux.intel.com>
CC: Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>,
        "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Slow file transfer speeds with CFQ IO scheduler in some cases
References: <492BE47B.3010802@vlnb.net> <20081125114908.GA16545@localhost> <492BE97A.3050606@vlnb.net> <492BEAE8.9050809@vlnb.net> <20081125121534.GA16778@localhost> <492EDCFB.7080302@vlnb.net> <20081128004830.GA8874@localhost> <49946BE6.1040005@vlnb.net> <20090213015721.GA5565@localhost> <4995D339.5050502@vlnb.net> <20090216023402.GA6199@localhost> <499B09FB.1070909@vlnb.net>
In-Reply-To: <499B09FB.1070909@vlnb.net>
Content-Type: multipart/mixed;
 boundary="------------060900030507000008050304"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------060900030507000008050304
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Vladislav Bolkhovitin, on 02/17/2009 10:03 PM wrote:
> Wu Fengguang, on 02/16/2009 05:34 AM wrote:
>> On Fri, Feb 13, 2009 at 11:08:25PM +0300, Vladislav Bolkhovitin wrote:
>>> Wu Fengguang, on 02/13/2009 04:57 AM wrote:
>>>> On Thu, Feb 12, 2009 at 09:35:18PM +0300, Vladislav Bolkhovitin wrote:
>>>>> Sorry for such a huge delay. There were many other activities I had 
>>>>> to  do before + I had to be sure I didn't miss anything.
>>>>>
>>>>> We didn't use NFS, we used SCST (http://scst.sourceforge.net) with   
>>>>> iSCSI-SCST target driver. It has similar to NFS architecture, where N 
>>>>>  threads (N=5 in this case) handle IO from remote initiators 
>>>>> (clients)  coming from wire using iSCSI protocol. In addition, SCST 
>>>>> has patch  called export_alloc_io_context (see   
>>>>> http://lkml.org/lkml/2008/12/10/282), which allows for the IO threads 
>>>>>  queue IO using single IO context, so we can see if context RA can   
>>>>> replace grouping IO threads in single IO context.
>>>>>
>>>>> Unfortunately, the results are negative. We find neither any 
>>>>> advantages  of context RA over current RA implementation, nor 
>>>>> possibility for  context RA to replace grouping IO threads in single 
>>>>> IO context.
>>>>>
>>>>> Setup on the target (server) was the following. 2 SATA drives grouped 
>>>>> in  md RAID-0 with average local read throughput ~120MB/s ("dd 
>>>>> if=/dev/zero  of=/dev/md0 bs=1M count=20000" outputs "20971520000 
>>>>> bytes (21 GB)  copied, 177,742 s, 118 MB/s"). The md device was 
>>>>> partitioned on 3  partitions. The first partition was 10% of space in 
>>>>> the beginning of the  device, the last partition was 10% of space in 
>>>>> the end of the device,  the middle one was the rest in the middle of 
>>>>> the space them. Then the  first and the last partitions were exported 
>>>>> to the initiator (client).  They were /dev/sdb and /dev/sdc on it 
>>>>> correspondingly.
>>>> Vladislav, Thank you for the benchmarks! I'm very interested in
>>>> optimizing your workload and figuring out what happens underneath.
>>>>
>>>> Are the client and server two standalone boxes connected by GBE?
>>> Yes, they directly connected using GbE.
>>>
>>>> When you set readahead sizes in the benchmarks, you are setting them
>>>> in the server side? I.e. "linux-4dtq" is the SCST server?
>>> Yes, it's the server. On the client all the parameters were left default.
>>>
>>>> What's the
>>>> client side readahead size?
>>> Default, i.e. 128K
>>>
>>>> It would help a lot to debug readahead if you can provide the
>>>> server side readahead stats and trace log for the worst case.
>>>> This will automatically answer the above questions as well as disclose
>>>> the micro-behavior of readahead:
>>>>
>>>>         mount -t debugfs none /sys/kernel/debug
>>>>
>>>>         echo > /sys/kernel/debug/readahead/stats # reset counters
>>>>         # do benchmark
>>>>         cat /sys/kernel/debug/readahead/stats
>>>>
>>>>         echo 1 > /sys/kernel/debug/readahead/trace_enable
>>>>         # do micro-benchmark, i.e. run the same benchmark for a short time
>>>>         echo 0 > /sys/kernel/debug/readahead/trace_enable
>>>>         dmesg
>>>>
>>>> The above readahead trace should help find out how the client side
>>>> sequential reads convert into server side random reads, and how we can
>>>> prevent that.
>>> We will do it as soon as we have a free window on that system.
>> Thank you. For NFS, the client side read/readahead requests will be
>> split into units of rsize which will be served by a pool of nfsd
>> concurrently and possibly out of order. Does SCST have the same
>> process? If so, what's the rsize value for your SCST benchmarks?
> 
> No, there is no such splitting in SCST. Client sees raw SCSI disks from 
> server and what client sends is directly and in full size sent by the 
> server to its backstorage using regular buffered read() 
> (fd->f_op->aio_read() followed by 
> wait_on_retry_sync_kiocb()/wait_on_sync_kiocb() to be precise).

Update. We ran the same tests with deadline I/O scheduler and had 
roughly the same results as with CFQ, see attachment.

> Thanks,
> Vlad
> 
> 


--------------060900030507000008050304
Content-Type: text/plain;
 name="2.6.27.12-except_export+readahead-4M-deadline.txt"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="2.6.27.12-except_export+readahead-4M-deadline.txt"

bGludXgtNGR0cTp+ICMgdW5hbWUgLXINCjIuNi4yNy4xMi1leGNlcHRfZXhwb3J0K3JlYWRhaGVh
ZA0KLXNjaGVkdWxlciA9IGRlYWRsaW5lDQotIFJBID0gNE0NCg0KDQpsaW51eC00ZHRxOn4gIyBm
cmVlDQogICAgICAgICAgICAgdG90YWwgICAgICAgdXNlZCAgICAgICBmcmVlICAgICBzaGFyZWQg
ICAgYnVmZmVycyAgICAgY2FjaGVkDQpNZW06ICAgICAgICA1MDgxNjggICAgIDExMTI4OCAgICAg
Mzk2ODgwICAgICAgICAgIDAgICAgICAgNDQ3NiAgICAgIDYyNjQ4DQotLysgYnVmZmVycy9jYWNo
ZTogICAgICA0NDE2NCAgICAgNDY0MDA0DQpTd2FwOiAgICAgICAgICAgIDAgICAgICAgICAgMCAg
ICAgICAgICAwDQoNCg0KbGludXgtNGR0cTp+ICMgZWNobyBkZWFkbGluZSA+IC9zeXMvYmxvY2sv
c2RiL3F1ZXVlL3NjaGVkdWxlcg0KbGludXgtNGR0cTp+ICMgZWNobyBkZWFkbGluZSA+IC9zeXMv
YmxvY2svc2RhL3F1ZXVlL3NjaGVkdWxlcg0KbGludXgtNGR0cTp+ICMgY2F0IC9zeXMvYmxvY2sv
c2RiL3F1ZXVlL3NjaGVkdWxlcg0Kbm9vcCBhbnRpY2lwYXRvcnkgW2RlYWRsaW5lXSBjZnENCmxp
bnV4LTRkdHE6fiAjIGNhdCAvc3lzL2Jsb2NrL3NkYS9xdWV1ZS9zY2hlZHVsZXINCm5vb3AgYW50
aWNpcGF0b3J5IFtkZWFkbGluZV0gY2ZxDQoNCmxpbnV4LTRkdHE6fiAjIGVjaG8gMSA+IC9zeXMv
YmxvY2svc2RhL3F1ZXVlL2NvbnRleHRfcmVhZGFoZWFkDQpsaW51eC00ZHRxOn4gIyBlY2hvIDEg
PiAvc3lzL2Jsb2NrL3NkYi9xdWV1ZS9jb250ZXh0X3JlYWRhaGVhZA0KbGludXgtNGR0cTp+ICMg
Y2F0IC9zeXMvYmxvY2svc2RiL3F1ZXVlL2NvbnRleHRfcmVhZGFoZWFkDQoxDQpsaW51eC00ZHRx
On4gIyBjYXQgL3N5cy9ibG9jay9zZGEvcXVldWUvY29udGV4dF9yZWFkYWhlYWQNCjENCg0KbGlu
dXgtNGR0cTp+ICMgYmxvY2tkZXYgLS1zZXRyYSA0MDk2IC9kZXYvc2RhDQpsaW51eC00ZHRxOn4g
IyBibG9ja2RldiAtLXNldHJhIDQwOTYgL2Rldi9zZGINCmxpbnV4LTRkdHE6fiAjIGJsb2NrZGV2
IC0tZ2V0cmEgL2Rldi9zZGINCjQwOTYNCmxpbnV4LTRkdHE6fiAjIGJsb2NrZGV2IC0tZ2V0cmEg
L2Rldi9zZGENCjQwOTYNCg0KbGludXgtNGR0cTp+ICMgbWRhZG0gLS1hc3NlbWJsZSAvZGV2L21k
MCAvZGV2L3NkW2FiXQ0KbWRhZG06IC9kZXYvbWQvMCBoYXMgYmVlbiBzdGFydGVkIHdpdGggMiBk
cml2ZXMuDQpsaW51eC00ZHRxOn4gIyB2Z2NoYW5nZSAtYSB5DQogIDMgbG9naWNhbCB2b2x1bWUo
cykgaW4gdm9sdW1lIGdyb3VwICJyYWlkIiBub3cgYWN0aXZlDQpsaW51eC00ZHRxOn4gIyBsdnMN
CiAgTFYgICBWRyAgIEF0dHIgICBMU2l6ZSAgIE9yaWdpbiBTbmFwJSAgTW92ZSBMb2cgQ29weSUg
IENvbnZlcnQNCiAgMXN0ICByYWlkIC13aS1hLSAgNDYuMDBHDQogIDJuZCAgcmFpZCAtd2ktYS0g
Mzc0LjAwRw0KICAzcmQgIHJhaWQgLXdpLWEtICA0Ni4wMEcNCg0Kc2NzdDogVXNpbmcgc2VjdXJp
dHkgZ3JvdXAgIkRlZmF1bHQiIGZvciBpbml0aWF0b3IgImlxbi4xOTk2LTA0LmRlLnN1c2U6MDE6
YWFkYWI4YmM0YmU1Ig0KaXNjc2ktc2NzdDoJCU5lZ290aWF0ZWQgcGFyYW1ldGVyczogSW5pdGlh
bFIyVCBObywgSW1tZWRpYXRlRGF0YSBZZXMsIE1heENvbm5lY3Rpb25zIDEsIE1heFJlY3ZEYXRh
U2VnbWVudExlbmd0aCAyNjIxNDQsIE1heFhtaXREYXRhU2VnbWVudExlbmd0aCAxMzEwNzIsDQpp
c2NzaS1zY3N0OiAgICAgTWF4QnVyc3RMZW5ndGggMTA0ODU3NiwgRmlyc3RCdXJzdExlbmd0aCAy
NjIxNDQsIERlZmF1bHRUaW1lMldhaXQgMiwgRGVmYXVsdFRpbWUyUmV0YWluIDAsDQppc2NzaS1z
Y3N0OiAgICAgTWF4T3V0c3RhbmRpbmdSMlQgMSwgRGF0YVBEVUluT3JkZXIgWWVzLCBEYXRhU2Vx
dWVuY2VJbk9yZGVyIFllcywgRXJyb3JSZWNvdmVyeUxldmVsIDAsDQppc2NzaS1zY3N0OiAgICAg
SGVhZGVyRGlnZXN0IE5vbmUsIERhdGFEaWdlc3QgTm9uZSwgT0ZNYXJrZXIgTm8sIElGTWFya2Vy
IE5vLCBPRk1hcmtJbnQgMjA0OCwgSUZNYXJrSW50IDIwNDgNCg0KMSkgZGQgaWY9L2Rldi9zZGIg
b2Y9L2Rldi9udWxsIGJzPTY0SyBjb3VudD04MDAwMA0KYSkgNTQsMSBNQi9zDQpiKSA1NSw2IE1C
L3MNCmMpIDU0LDMgTUIvcw0KDQoyKSBkZCBpZj0vZGV2L3NkYyBvZj0vZGV2L251bGwgYnM9NjRL
IGNvdW50PTgwMDAwDQphKSA3MSwzIE1CL3MNCmIpIDczLDggTUIvcw0KYykgNzIsNyBNQi9zDQoN
CjMpUnVuIGF0IHRoZSBzYW1lIHRpbWU6CQ0Kd2hpbGUgdHJ1ZTsgZG8gZGQgaWY9L2Rldi9zZGMg
IG9mPS9kZXYvbnVsbCBicz02NEs7IGRvbmUJDQpkZCBpZj0vZGV2L3NkYiBvZj0vZGV2L251bGwg
YnM9NjRLIGNvdW50PTgwMDAwDQphKSA0LDMgTUIvcw0KYikgNS4wIE1CL3MgDQpjKSA1LjIgTUIv
cw==

--------------060900030507000008050304--
