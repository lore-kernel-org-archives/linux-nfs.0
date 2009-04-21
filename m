From: =?iso-8859-1?Q?Andr=E9?= Berger <andre.berger-S0/GAf8tV78@public.gmane.org>
Subject: Re: NFS issues with recent kernels [long]
Date: Tue, 21 Apr 2009 06:36:43 +0200
Message-ID: <20090421043642.GA52257@fuchs>
References: <20090417102659.GC55096@fuchs> <B05C16C7-53B5-4E26-8239-956C600CF452@oracle.com> <20090420091454.GB614@fuchs> <F1250240-F050-47B7-9569-54941AAAD572@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:53219 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbZDUEgr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 00:36:47 -0400
In-Reply-To: <F1250240-F050-47B7-9569-54941AAAD572@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Chuck Lever (2009-04-20):
> On Apr 20, 2009, at 5:14 AM, Andr=E9 Berger wrote:
>> * Chuck Lever (2009-04-17):
>>> Copying linux-nfs@vger.kernel.org, please follow up there.
>>
>> OK, here we go. If anyone here doesn't want to receive these
>> messages, please let me know.
>>
>> It took me a while to get a tcpdump binary for the dbox2, hence the
>> delay and extensive quotes. The libc6 for tcpdump is itself located
>> on a NFS share.
>
>   [ ... ]
>
>>> You could try capturing a raw packet trace of the initial mount and=
 a=20
>>> few
>>> reads and write on the share.  The clients negotiate the rsize and =
=20
>>> wsize
>>> settings with the server, and the packet dump would expose the =20
>>> negotiated
>>> values.
>>>
>>> On your clients, use "tcpdump -s 0 -w /tmp/raw host" followed by th=
e=20
>>> DNS
>>> name of your server.  Then attach the raw pcap files to e-mail (as =
=20
>>> long as
>>> they are less than 100KB or so) and post them to linux-nfs-u79uwXL29TY@public.gmane.org=
nel.org
>>
>> Here you go. The host "192.168.1.8 hg linkstation" is specified in
>> /etc/hosts.
>>
>>>> For the sake of completeness, my router is a Linksys WRT54G
>>>>
>>>> with Tomato firmware
>>>>
>>>> <http://www.polarcloud.com/tomato_123>
>>>>
>>>> and a MTU of 1492 throughout the network.
>>>>
>>>> If there is anything I can do to help troubleshooting, please let =
me
>>>> know.
>
> I got two copies of this e-mail.  One has a 24KB PCAP file called "ra=
w"=20
> and the other has a 90KB file called "xap" that does not appear to be=
 a=20
> PCAP file.

The first message was too big for the list and bounced (172 KB). For
the second one (90KB raw size), I was unable to produce a dump small
enough, so I used split on it. I might have sent the wrong part
though.=20

> I looked at "raw" and it's hard to make sense of it.  I see both UDP =
and=20
> TCP traffic, and both NFSv2 and NFSv3 requests.  I guess this is beca=
use=20
> tcpdump is on NFS.  It would be better if you could copy the tcpdump=20
> binary to a local file system on the client before running the test t=
o=20
> avoid the extra traffic.

Space is very limited on the dbox, so I had to try and compile the
dbox2 Neutrino OS with tcpdump during the last couple of days.
Yesterday I succeeded, so I hope to boot the beast today.=20

> You should avoid UDP on this network at all costs, especially if you =
want=20
> to use large r/wsize.  It's likely that this is the real performance=20
> issue.  Specify "proto=3Dtcp" on your mount command line to force the=
 use of=20
> NFS/TCP.  Otherwise IP packet fragmentation and reassembly will cause=
=20
> dropped RPC requests, exacerbated by network link speed mismatches an=
d=20
> Ethernet frame collision on the half-duplex links.
>
> I believe the older 2.4-based NFS clients will use UDP by default.

Weird, I always got the best results with UDP for writing and TCP for
reading.=20

I'll try and produce a better, short tcpdump as soon as I can.

-Andr=E9

--=20
May as well be hung for a sheep as a lamb!
Linkstation/KuroBox/HG/HS/Tera Kernel 2.6/PPC from <http://hvkls.dyndns=
=2Eorg>
iPhone <http://hvkls.dyndns.org/downloads/documentation/README-iphone.h=
tml>
