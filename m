From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS issues with recent kernels [long]
Date: Fri, 8 May 2009 16:00:56 -0400
Message-ID: <8D7394C9-0142-4635-88E5-139F4F5F39F6@oracle.com>
References: <20090417102659.GC55096@fuchs> <B05C16C7-53B5-4E26-8239-956C600CF452@oracle.com> <20090420091454.GB614@fuchs> <F1250240-F050-47B7-9569-54941AAAD572@oracle.com> <20090421043642.GA52257@fuchs> <20090508193813.GC3801@fuchs>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>
To: =?ISO-8859-1?Q?Andr=E9_Berger?= <andre.berger-S0/GAf8tV78@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:19695 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbZEHUBD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2009 16:01:03 -0400
In-Reply-To: <20090508193813.GC3801@fuchs>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 8, 2009, at 3:38 PM, Andr=E9 Berger wrote:
> * Andr=E9 Berger (2009-04-21):
>> * Chuck Lever (2009-04-20):
>>> On Apr 20, 2009, at 5:14 AM, Andr=E9 Berger wrote:
>>>> * Chuck Lever (2009-04-17):
>>>>> Copying linux-nfs@vger.kernel.org, please follow up there.
>>>>
>>>> OK, here we go. If anyone here doesn't want to receive these
>>>> messages, please let me know.
>>>>
>>>> It took me a while to get a tcpdump binary for the dbox2, hence th=
e
>>>> delay and extensive quotes. The libc6 for tcpdump is itself locate=
d
>>>> on a NFS share.
>>>
>>>  [ ... ]
>>>
>>>>> You could try capturing a raw packet trace of the initial mount =20
>>>>> and a
>>>>> few
>>>>> reads and write on the share.  The clients negotiate the rsize an=
d
>>>>> wsize
>>>>> settings with the server, and the packet dump would expose the
>>>>> negotiated
>>>>> values.
>>>>>
>>>>> On your clients, use "tcpdump -s 0 -w /tmp/raw host" followed by =
=20
>>>>> the
>>>>> DNS
>>>>> name of your server.  Then attach the raw pcap files to e-mail (a=
s
>>>>> long as
>>>>> they are less than 100KB or so) and post them to linux-nfs@vger.k=
ernel.org
>>>>
>>>> Here you go. The host "192.168.1.8 hg linkstation" is specified in
>>>> /etc/hosts.
>>>>
>>>>>> For the sake of completeness, my router is a Linksys WRT54G
>>>>>>
>>>>>> with Tomato firmware
>>>>>>
>>>>>> <http://www.polarcloud.com/tomato_123>
>>>>>>
>>>>>> and a MTU of 1492 throughout the network.
>>>>>>
>>>>>> If there is anything I can do to help troubleshooting, please =20
>>>>>> let me
>>>>>> know.
>>>
>>> I got two copies of this e-mail.  One has a 24KB PCAP file called =20
>>> "raw"
>>> and the other has a 90KB file called "xap" that does not appear to =
=20
>>> be a
>>> PCAP file.
>>
>> The first message was too big for the list and bounced (172 KB). For
>> the second one (90KB raw size), I was unable to produce a dump small
>> enough, so I used split on it. I might have sent the wrong part
>> though.
>>
>>> I looked at "raw" and it's hard to make sense of it.  I see both =20
>>> UDP and
>>> TCP traffic, and both NFSv2 and NFSv3 requests.  I guess this is =20
>>> because
>>> tcpdump is on NFS.  It would be better if you could copy the tcpdum=
p
>>> binary to a local file system on the client before running the =20
>>> test to
>>> avoid the extra traffic.
>>
>> Space is very limited on the dbox, so I had to try and compile the
>> dbox2 Neutrino OS with tcpdump during the last couple of days.
>> Yesterday I succeeded, so I hope to boot the beast today.
>>
>>> You should avoid UDP on this network at all costs, especially if =20
>>> you want
>>> to use large r/wsize.  It's likely that this is the real performanc=
e
>>> issue.  Specify "proto=3Dtcp" on your mount command line to force =20
>>> the use of
>>> NFS/TCP.  Otherwise IP packet fragmentation and reassembly will =20
>>> cause
>>> dropped RPC requests, exacerbated by network link speed mismatches =
=20
>>> and
>>> Ethernet frame collision on the half-duplex links.
>>>
>>> I believe the older 2.4-based NFS clients will use UDP by default.
>>
>> Weird, I always got the best results with UDP for writing and TCP fo=
r
>> reading.
>>
>> I'll try and produce a better, short tcpdump as soon as I can.
>
> After some difficulties, here we go!
>
> -Andr=E9
>
> --
> May as well be hung for a sheep as a lamb!
> Linkstation/KuroBox/HG/HS/Tera Kernel 2.6/PPC from <http://hvkls.dynd=
ns.org=20
> >
> iPhone <http://hvkls.dyndns.org/downloads/documentation/README-iphone=
=2Ehtml=20
> >
> <raw>

Assuming 192.168.1.8 is your server, frame 79 and 622 report FSINFO =20
results:

Network File System, FSINFO Reply
     [Program Version: 3]
     [V3 Procedure: FSINFO (19)]
     Status: NFS3_OK (0)
     obj_attributes
         attributes_follow: no value (0)
     rtmax: 16384
     rtpref: 16384
     rtmult: 4096
     wtmax: 16384
     wtpref: 16384
     wtmult: 4096
     dtpref: 4096
     maxfilesize: 2194719883264
     time delta: 1.000000000 seconds
         seconds: 1
         nano seconds: 0
     Properties: 0x0000001b
         1... . =3D SETATTR can set time on server
         .1.. . =3D PATHCONF is valid for all files
         ...1 . =3D File System supports symbolic links
         .... 1 =3D File System supports hard links

says your server operating system supports NFS rsize and wsize maxima =20
of 16384 bytes.

RFC 1813:
> rtmax
> The maximum size in bytes of a READ request supported by the server. =
=20
> Any READ with a number greater than rtmax will result in a short =20
> read of rtmax bytes or less.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com