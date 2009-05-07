From: Aaron Wiebe <epiphani@gmail.com>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Thu, 7 May 2009 14:08:55 -0400
Message-ID: <e7ca40f70905071108v62fc3d7ds3174ddaf0e73c6a8@mail.gmail.com>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
	<c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>
	<4A02FDC3.9090709@bio.ifi.lmu.de>
	<4a02ffdf.1ac1f10a.637d.ffffbc3a@mx.google.com>
	<e7ca40f70905070908p595c1d23gef745a122ae09caa@mail.gmail.com>
	<C8BD2645-6EFC-4669-9074-B57C08B2EF70@oracle.com>
	<4a031594.1c1d640a.6d45.5fed@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>,
	Leonardo Chiquitto <leonardo.lists@gmail.com>,
	Chuck Lever <chuck.lever@oracle.com>, nfs@lists.sourceforge.net
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51249 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123AbZEGSLM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2009 14:11:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M283p-0007RA-3N
	for linux-nfs@vger.kernel.org; Fri, 08 May 2009 04:11:09 +1000
In-Reply-To: <4a031594.1c1d640a.6d45.5fed-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 7, 2009 at 1:08 PM, Tom Talpey <tmtalpey@gmail.com> wrote:
> At 12:42 PM 5/7/2009, Chuck Lever wrote:
>>It's not portmap... lockd decides which listeners to start.

Thanks Chuck and Tom - that clarifies it.

Take care,
-Aaron

> Also, there is an important distinction between NLM and NLM *callback=
s*.
> The NLM client follows the NFS protocol selection in many client kern=
els,
> i.e. if you mount with proto=3Dtcp, you get both NFS and NLM over TCP=
=2E
>
> The issue is NLM callbacks, which are used only in specific cases whe=
re
> clients take blocking locks, which actually need to block due to bein=
g already
> held by another client. The server replies over NLM (e.g. TCP) with a=
n indication
> that a callback will arive later. But when the other lock is released=
, the callback
> comes on a second connection, initiated from the server back to the c=
lient and
> not on the original NLM channel. To make matters worse, some servers =
only
> ever perform the callback on UDP in order to simplify and reduce the =
overhead
> required.
>
> If this callback doesn't arrive at the client, or arrives in such a w=
ay that
> it's not recognized (e.g traverses a NAT and therefore changes source=
 IP),
> then the client only wakes up on a timer. The long pauses can be a re=
al
> problem, and one which only arises occasionally - i.e. very hard to t=
race down.
>
> Just something to be aware of... it's a day-one defect in the NLM pro=
tocol,
> actually.
>
> Tom.
>
>>
>>> =A0I know there
>>> are servers out there that will always speak NLM over UDP
>>> (netapp/ontap being the prominent one), and as a result there can b=
e
>>> problems without firewalls. =A0If servers are out there that will s=
peak
>>> NLM over UDP regardless of the mount itself, shouldn't we be bindin=
g
>>> NLM/UDP regardless of the mount transport?
>>>
>>> (Or did I miss this change being reverted a while back?)
>>
>>This change was reverted upstream; see commit 8c3916f4.
>>
>>--
>>Chuck Lever
>>chuck[dot]lever[at]oracle[dot]com
>>
>
>

-----------------------------------------------------------------------=
-------
The NEW KODAK i700 Series Scanners deliver under ANY circumstances! You=
r
production scanning environment may not be a perfect world - but thanks=
 to
Kodak, there's a perfect scanner to get the job done! With the NEW KODA=
K i700
Series Scanner you'll get full speed at 300 dpi even with all image=20
processing features enabled. http://p.sf.net/sfu/kodak-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

