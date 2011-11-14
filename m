Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp02.citrix.com ([66.165.176.63]:38526 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754112Ab1KNNQ4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 08:16:56 -0500
Message-ID: <4EC114BD.1010600@citrix.com>
Date: Mon, 14 Nov 2011 13:16:45 +0000
From: Andrew Cooper <andrew.cooper3@citrix.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: unexpected NFS timeouts, related to sync/async soft mounts over
 TCP
References: <4EBAC88D.40902@citrix.com>		 <BEF32B02-0D19-4D97-8E93-C1797DF02CFE@oracle.com>		 <4EBBB247.40805@citrix.com>		 <2E3D3F87-479E-4096-B086-C8F83A0147B5@oracle.com>		 <4EBBF35B.5000606@citrix.com>	 <1320957784.11956.16.camel@lade.trondhjem.org>	 <4EBCF98E.6050101@citrix.com> <1321051132.4810.16.camel@lade.trondhjem.org>
In-Reply-To: <1321051132.4810.16.camel@lade.trondhjem.org>
Content-Type: multipart/mixed;
	boundary="------------030607000902090300010208"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--------------030607000902090300010208
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On 11/11/11 22:38, Trond Myklebust wrote:
> On Fri, 2011-11-11 at 10:31 +0000, Andrew Cooper wrote: 
>> On 10/11/11 20:43, Trond Myklebust wrote:
>>> On Thu, 2011-11-10 at 15:52 +0000, Andrew Cooper wrote: 
>>>> On 10/11/11 15:29, Chuck Lever wrote:
>>>>> On Nov 10, 2011, at 6:15 AM, Andrew Cooper wrote:
>>>>>
>>>>>> On 09/11/11 22:36, Chuck Lever wrote:
>>>>>>> On Nov 9, 2011, at 1:38 PM, Andrew Cooper wrote:
>>>> Sorry.  I am not sure I was clear.  An EIO does not present itself with
>>>> a hard mount, but a TCP FIN is still injected into the stream by the
>>>> client, causing 15 seconds of deadlock, eventually fixed by sending a
>>>> RST and restarting with a new TCP stream.  At this point, softmounts
>>>> throw an EIO while hardmounts restart and continue successfully.
>>>>
>>>> My problem is not the EIO on softmount or lack of EIO for hardmout, but
>>>> the fact that the client sees fit to try and close the TCP stream while
>>>> an apparently otherwise healthy NFS session is ongoing.
>>> The client will attempt to close the TCP connection on any RPC level
>>> error. That can happen, e.g., if the server sends a faulty RPC/TCP
>>> record fragment header or some other garbage data.
>>>
>>> I'm assuming that you've checked that the TCP parameters are set to sane
>>> values for a 10GigE connection (i.e. tcp_timestamps is on) so that there
>>> is no corruption happening at that level?
>>>
>>> Cheers
>>>   Trond
>> I have a TCPdump/wireshark analysis of the entire packet stream (4GiB). 
>> I cant see any RPC level errors (rpc.replystat != 0 yields no matches). 
>> What specifically would I be looking for?  Wireshark seems not to have
>> any problem decoding any of the RPC packets, so I hope that indicates no
>> RPC level corruption.
>>
>> There is one case where the server sends a double write reply for the
>> same write, with different length fields.  However, this is a good 20
>> seconds before the FIN is sent, so I was hoping that it was unrelated.
>> Might it not be?
> Can you send us just that portion of the trace so that we can have a look?

Attached is a small extract from the stream.  It starts with the final
NFS write, and continues through the FIN, RST and until the TCP stream
gets reopened.  Is this what you want?

>> As for TCP timestamps; I have a Timestamp option in each TCP packet. 
>> Nothing appears corrupted.  What would I be looking for with corrupted
>> timestamps?
> I just meant that you should check that you've enabled tcp window
> scaling and timestamps in order to avoid problems with wrapped sequence
> numbers (See  http://tools.ietf.org/html/rfc1323 for details).
>
> On Linux this means that you need to check
>
> 	sysctl net.ipv4.tcp_timestamps
> and
> 	sysctl net.ipv4.tcp_window_scaling
>
> They should both be set to the value '1'.

They both are.

> Cheers
>   Trond
>
-- 
Andrew Cooper - Dom0 Kernel Engineer, Citrix XenServer
T: +44 (0)1223 225 900, http://www.citrix.com


--------------030607000902090300010208
Content-Type: application/x-gzip; name="nfs-fin.capture.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="nfs-fin.capture.gz"

H4sICAYQwU4AA25mcy1maW4uY2FwdHVyZQDtnX1MlVUcx8/zXC4wtAXoEM2KQrtwrauCiC9E
N5tFpFhr+R4vl5dUhjpx2YvTO6fORkNTxizLYelWmRumMbU7SFEgLMXUwl70jxAc5ab+4wCd
nd957kM8L574pzbp+9mOD5eXzz3Pj3PP4/M9Z5dz9V/uUlkI07lzhzGFH2PmH85S5zrYVhcT
Ta3aft+YmtazG+p2VYSz6cy1PvC2l3lDRzgjnq0o4M3hqAtXrmYNj77Z0rOuOrKrtWAJNynh
ESwy56Qam/2bojgjbrbceoy3ZgYAAAAAAAAAAAAAAAAAADDA8Svsi9bJyYeCD1WmbPyEHx28
hTFtQWYGY4md/DgyP6/El1KY7Bs/0ZO/qPTN0iRP/uKVKxa/4clfVtJHGRY8KsKnuWiZJ5S3
iD7fF1fA/0l7auOoOO1x0crkfa6KjP1DvPzB+ffTxCc7GnM1k24EAAAAAAAAAPCfQTv0nHMd
bBr/mJq2N0/bp0c79NiEun20Qy89nnbn0S69cMVRR7vvrs5sd/sju699/rC2Q0+Nzb5Ou/TI
OJgbbwxiopn3/A1qC6wjY8pO454/72x9z19GM/b8AQAAAAAAcK9AdwD3S+8pvhH3FE/a3FNc
f4vuKXaett5TDOPGR6OYaOZ7iqihgQ1kHFdsvKd4oVu/p5jZjXsKAAAAAAAAAAAADCwoMRkh
zWCOigwmzSaDudVMGcy2tdYMJl6ewWwSGcwiYwaz8BQyGAAAAAAAAAAAAAxUKDEZLc1gjokM
Zqo1g8kKH0EZzKax1gzGI89gykQGU2jMYEo+RgYDAAAAAAAAAACAgQolJuOkGUy9yGCm2GQw
Q5ZQBrP6kjWDmSTPYMpFBuMzZjBrXkcGAwAAAAAAAAAAgIEKJSavSDOY4yKDmWyTwYzKpAym
+I41g/Fx4/yRTDRzBjNyRuA9Mo52GTOYzZl6BjMvCRkMAAAAAAAAAAAAAAAAAAAAAP83aKWx
QLp2eUKsXU6yWbtMeYjWLheMsa5dlnBjbQwTzbx2GVMdqCSju9a4drm39+/jvVyJtUsAAAAA
AAAAAAAAAAAA/y6UZi+X5uMNIh9PtcnHp9+gfDxzjjUfX8WNnU4mmjkfd/4a+EC8a265MR8/
2qDn49OOIR8HAIB7CZr5V/OZf7bCRDPP/EpGYAfN/N5HjDN/o0/M/MO7WtM9mPn/CaryeukV
u1FcsSfaXLFfqqQrdvoB6xX7HamxSRhTbIw+8R5rT9i8x9q7UuO3wjjBxliaTsYHB1mNO6TG
ZmFMtjGujybj4FSr8YDUeFIYk2yMFe1k7PFZjYekxu+EcbyNcc8RMnaWW41fS43fC+M4G2NN
ORkvHLEaT0uNp4RxrI2x0UfGpnarsUNqPC2MHhtjU7E/sutK02WrsWieg/EnEs1ibG0RxsfX
2hpju6+tMv3tSz9jVT9NTj7EZcpdXlbi8x0NuSzr8PyYsbsvLtePwa/xpuw2/3xHY644Xkkz
yobsz6gIfliUVe2aF/HLmibN15mgH4Mm9bnbB7L01/Uyftb0gJp59mTewId01k8nGGfPpmL9
/8171bvNnreXkj3htVDm4d9DzVxTNe6MqKk71VjTnnV6TaMu6DXNceo1Pd+fmh7XahpflrdI
P0preiJY0yn9q2l8WUmcfjTXlPr4Y3/6eELvYx+XrI8NwT5O7V8fDePJpo/3wticxEePZGx+
JMamyzo2by+lsfnpz71j8xKNoL5jczS3t7lY7wxisU8I7BT2JDu7f2hX67EVur1wK9kT6B0r
EhnLZFqzGNP2/E7GOZcNxln1r9LZVqkxLWfC+E+FOA+GqGQtqhW/BoeDkfmzRNZbCcvc5P1B
vI7GDOv7Otr21RaV27Oro7uvzXpAMytKiEpG7TVV2EbPQvaaRFkl9rSJfv9p6nc2fwaHPzKm
ZWWYXomiWrKS8aLceFkY/7A1RnFjqNUY72aS+f6sNpPEmyrg4NYcuoJs7p3v/z7rqVLjOWFM
tDdGcWOb1fiMW3rW7eKsO01nncOtIaKOTutZ57ilI+qijfHF+tzgiKpaPN44osjKf/+hZD7o
lo2o8+LsEwwjqqYs53luz6MRtbBbPqJq5ZW4JPp93dTvPP4Mmf5ItmD7AmMl/gIpXbubLMAA
AA==
--------------030607000902090300010208--
