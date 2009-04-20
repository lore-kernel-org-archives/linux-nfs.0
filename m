From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS issues with recent kernels [long]
Date: Mon, 20 Apr 2009 15:07:49 -0400
Message-ID: <F1250240-F050-47B7-9569-54941AAAD572@oracle.com>
References: <20090417102659.GC55096@fuchs> <B05C16C7-53B5-4E26-8239-956C600CF452@oracle.com> <20090420091454.GB614@fuchs>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>
To: =?ISO-8859-1?Q?Andr=E9_Berger?= <andre.berger-S0/GAf8tV78@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:36149 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbZDTTID convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Apr 2009 15:08:03 -0400
In-Reply-To: <20090420091454.GB614@fuchs>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 20, 2009, at 5:14 AM, Andr=E9 Berger wrote:
> * Chuck Lever (2009-04-17):
>> Copying linux-nfs@vger.kernel.org, please follow up there.
>
> OK, here we go. If anyone here doesn't want to receive these
> messages, please let me know.
>
> It took me a while to get a tcpdump binary for the dbox2, hence the
> delay and extensive quotes. The libc6 for tcpdump is itself located
> on a NFS share.

   [ ... ]

>> You could try capturing a raw packet trace of the initial mount and =
=20
>> a few
>> reads and write on the share.  The clients negotiate the rsize and =20
>> wsize
>> settings with the server, and the packet dump would expose the =20
>> negotiated
>> values.
>>
>> On your clients, use "tcpdump -s 0 -w /tmp/raw host" followed by =20
>> the DNS
>> name of your server.  Then attach the raw pcap files to e-mail (as =20
>> long as
>> they are less than 100KB or so) and post them to linux-nfs-u79uwXL29Tb/PtFMR13I2A@public.gmane.org=
el.org
>
> Here you go. The host "192.168.1.8 hg linkstation" is specified in
> /etc/hosts.
>
>>> For the sake of completeness, my router is a Linksys WRT54G
>>>
>>> with Tomato firmware
>>>
>>> <http://www.polarcloud.com/tomato_123>
>>>
>>> and a MTU of 1492 throughout the network.
>>>
>>> If there is anything I can do to help troubleshooting, please let m=
e
>>> know.

I got two copies of this e-mail.  One has a 24KB PCAP file called =20
"raw" and the other has a 90KB file called "xap" that does not appear =20
to be a PCAP file.

I looked at "raw" and it's hard to make sense of it.  I see both UDP =20
and TCP traffic, and both NFSv2 and NFSv3 requests.  I guess this is =20
because tcpdump is on NFS.  It would be better if you could copy the =20
tcpdump binary to a local file system on the client before running the =
=20
test to avoid the extra traffic.

You should avoid UDP on this network at all costs, especially if you =20
want to use large r/wsize.  It's likely that this is the real =20
performance issue.  Specify "proto=3Dtcp" on your mount command line to=
 =20
force the use of NFS/TCP.  Otherwise IP packet fragmentation and =20
reassembly will cause dropped RPC requests, exacerbated by network =20
link speed mismatches and Ethernet frame collision on the half-duplex =20
links.

I believe the older 2.4-based NFS clients will use UDP by default.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com