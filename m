From: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Subject: Re: NFS/Kernel Problem: getfh failed: Operation not permitted
Date: Thu, 30 Mar 2006 11:14:11 -0500
Message-ID: <Pine.LNX.4.61.0603301111421.738@chaos.analogic.com>
References: <Pine.LNX.4.64.0603300813270.18696@p34> <1143728720.8074.41.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603300929340.18696@p34> <1143729766.8074.49.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603300949000.18696@p34> <1143731364.8074.53.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603301011160.18696@p34> <20060330153128.GB9811@unthought.net> <Pine.LNX.4.61.0603301053030.738@chaos.analogic.com> <20060330160521.GC9811@unthought.net>
Reply-To: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Justin Piszcz" <jpiszcz@lucidpixels.com>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	<linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751159AbWC3QOR@vger.kernel.org>
in-reply-to: <20060330160521.GC9811@unthought.net>
To: "Jakob Oestergaard" <jakob@unthought.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Thu, 30 Mar 2006, Jakob Oestergaard wrote:

> On Thu, Mar 30, 2006 at 10:58:08AM -0500, linux-os (Dick Johnson) wrote:
> ...
>> This is my /etc/exports and it works fine with linux-2.6.15.4.
>> All the host names are local, inside the firewall, and need to
>> be looked-up over a W$<crap> name-server.
>>
>> #
>> /rmtboot/LinuxRoot	*(ro,async)
>> /root/Scanner	*(ro,no_root_squash,sync)
>> /tmp		*(rw,no_root_squash,sync)
>> /usr/src	quark(rw,no_root_squash,sync)
>> /usr/lib	quark(rw,no_root_squash,sync)
> ...
>
> Well lucky you  :)
>
> I'm not saying it can't work. I'm just saying I've spent too much time
> finding out the hard way that it does not necessarily work  :)
>
> --

>
> / jakob
>

Well NFS is supposed to work like this. If it doesn't, you may
have some far more serious problems, perhaps duplicate IP addresses,
etc., that prevent proper resolution and subsequent connections.
It has nothing to do with luck.

Cheers,
Dick Johnson
Penguin : Linux version 2.6.15.4 on an i686 machine (5589.42 BogoMips).
Warning : 98.36% of all statistics are fiction, book release in April.
_


****************************************************************
The information transmitted in this message is confidential and may be privileged.  Any review, retransmission, dissemination, or other use of this information by persons or entities other than the intended recipient is prohibited.  If you are not the intended recipient, please notify Analogic Corporation immediately - by replying to this message or by sending an email to DeliveryErrors@analogic.com - and destroy all copies of this information, including any attachments, without reading or disclosing them.

Thank you.
