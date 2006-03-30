From: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Subject: Re: NFS/Kernel Problem: getfh failed: Operation not permitted
Date: Thu, 30 Mar 2006 10:58:08 -0500
Message-ID: <Pine.LNX.4.61.0603301053030.738@chaos.analogic.com>
References: <Pine.LNX.4.64.0603300813270.18696@p34> <1143728720.8074.41.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603300929340.18696@p34> <1143729766.8074.49.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603300949000.18696@p34> <1143731364.8074.53.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603301011160.18696@p34> <20060330153128.GB9811@unthought.net>
Reply-To: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Justin Piszcz" <jpiszcz@lucidpixels.com>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	<linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751184AbWC3P6S@vger.kernel.org>
in-reply-to: <20060330153128.GB9811@unthought.net>
To: "Jakob Oestergaard" <jakob@unthought.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Thu, 30 Mar 2006, Jakob Oestergaard wrote:

> On Thu, Mar 30, 2006 at 10:13:38AM -0500, Justin Piszcz wrote:
>> On Thu, 30 Mar 2006, Trond Myklebust wrote:
>>
> ...
>> In the /etc/exports file, I have an entry that looks like this:
>> /path	specific-host-001(ro,root_squash,no_sync)
>> /path	specific-host-002((ro,root_squash,no_sync)
>> /path	*(ro,root_squash,no_sync)
>
> I don't know how this works today, but historically Linux has been
> completely unable to deal with any kind of names in /etc/exports.
> Netgroups, DNS names, ...  And the results have been the strangest mix
> of things sort-of-mostly-but-not-quite working.
>
> I'd put in IP addresses, netmasks or '*', and see if that solves the
> problem.
>
> Again, I don't know if this is related to what you're seeing, but I'd
> say it's worth a shot :)
>
> --

>
> / jakob
>


This is my /etc/exports and it works fine with linux-2.6.15.4.
All the host names are local, inside the firewall, and need to
be looked-up over a W$<crap> name-server.

#
/rmtboot/LinuxRoot	*(ro,async)
/root/Scanner	*(ro,no_root_squash,sync)
/tmp		*(rw,no_root_squash,sync)
/usr/src	quark(rw,no_root_squash,sync)
/usr/lib	quark(rw,no_root_squash,sync)
/home/hpbd	*(rw,no_root_squash,sync)
/exports	*(rw,no_root_squash,sync)
/home/project/boneserver	*(rw,no_root_squash,sync)
/root		groveland(rw,no_root_squash,sync)
/root		quark(rw,no_root_squash,sync)
/root/DAS	*(ro,no_root_squash,sync)
/dos/drive_C	*(ro,sync)
# End of exports.


Cheers,
Dick Johnson
Penguin : Linux version 2.6.15.4 on an i686 machine (5589.42 BogoMips).
Warning : 98.36% of all statistics are fiction, book release in April.
_


****************************************************************
The information transmitted in this message is confidential and may be privileged.  Any review, retransmission, dissemination, or other use of this information by persons or entities other than the intended recipient is prohibited.  If you are not the intended recipient, please notify Analogic Corporation immediately - by replying to this message or by sending an email to DeliveryErrors@analogic.com - and destroy all copies of this information, including any attachments, without reading or disclosing them.

Thank you.
