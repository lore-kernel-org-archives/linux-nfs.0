Return-Path: linux-nfs-owner@vger.kernel.org
Received: from inspiron.ap.columbia.edu ([128.59.145.39]:48469 "EHLO
	inspiron.ap.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755921Ab2CLVYK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 17:24:10 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
To: linux-nfs@vger.kernel.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
References: <878vj7x6mj.fsf@vostro.rath.org>
	<87pqchn64e.fsf@inspiron.ap.columbia.edu>
	<20120312193115.GA7203@fieldses.org> <4F5E5241.7070008@rath.org>
	<20120312201505.GC7203@fieldses.org>
Date: Mon, 12 Mar 2012 17:24:09 -0400
In-Reply-To: <20120312201505.GC7203@fieldses.org> (J. Bruce Fields's message
	of "Mon, 12 Mar 2012 16:15:05 -0400")
Message-ID: <87mx7lms1y.fsf@inspiron.ap.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> writes:
> On Mon, Mar 12, 2012 at 03:45:05PM -0400, Nikolaus Rath wrote:
>> On 03/12/2012 03:31 PM, J. Bruce Fields wrote:
>> > On Mon, Mar 12, 2012 at 12:20:17PM -0400, Nikolaus Rath wrote:
>> >> Nikolaus Rath <Nikolaus-BTH8mxji4b0-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org> writes:
>> >>> The problem is that as soon as more than three clients are accessing the
>> >>> NFS shares, any operations on the NFS mountpoints by the clients hang.
>> >>> At the same time, CPU usage of the VPN processes becomes very high. If I
>> >>> run the VPN in debug mode, all I can see is that it is busy forwarding
>> >>> lots of packets. I also ran a packet sniffer which showed me that 90% of
>> >>> the packets were NFS related, but I am not familiar enough with NFS to
>> >>> be able to tell anything from the packets themselves. I can provide an
>> >>> example of the dump if that helps.
>> >>
>> >> I have put a screenshot of the dump on
>> >> http://www.rath.org/res/wireshark.png (the full dump is 18 MB, and I'm
>> >> not sure which parts are important).
>> > 
>> > Looks like they're doing SETCLIENTID, SETCLIENTID_CONFIRM, OPEN,
>> > OPEN_CONFIRM repeatedly.
>> > 
>> >> Any suggestions how I could further debug this?
>> > 
>> > Could the clients be stepping on each others' state if they all think
>> > they have the same IP address (because of something to do with the VPN
>> > networking?)
>> 
>> That sounds like promising path of investigation. What determines the IP
>> of a client as far as NFS is concerned?
>
> I don't remember where it gets the ip it uses to construct clientid's
> from....  But there is a mount option (clientaddr=) that will let you
> change what it uses.  So it *might* be worth checking whether using a
> clientaddr= option on each client (giving it a different ipaddr on each
> client) would change the behavior.

Alright, it seems that this was the problem. With correct clientaddr, I
haven't been able to produce any freezes for the last 15 minutes
(usually it happens in ~20 seconds).

The weird thing is that I cannot reproduce the wrong clientaddr
autodetection when I mount the NFS volumes from the command line. It
seems to happen only when the mounting is done by mountall during the
boot sequence.

In other words, this fstab entry results in freezes and a clientaddr of 0.0.0.0:

spitzer:/opt /opt        nfs4    bg 0  0

While this one, followed by a "mount /opt" on the console as soon as I'm
able to log in, works just fine (and has a correct cliendaddr):

spitzer:/opt /opt        nfs4    noauto 0  0


I'd be happy to help debugging the failing autodetection, but apparently
it's not going to be as simple as "strace mount /opt".

Are there any Ubuntu exports here? I tried debugging mountall once, and
it was a very painful experience. I can't just strace it, because when
it's called there is no writable file system to write the logs into...


Thanks a lot for your help Bruce!


Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
