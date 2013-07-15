Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:54276 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758329Ab3GOXcH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jul 2013 19:32:07 -0400
Message-ID: <51E48670.9070901@candelatech.com>
Date: Mon, 15 Jul 2013 16:32:00 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Dean <seattleplus@gmail.com>, "J.Bruce Fields" <bfields@citi.umich.edu>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
References: <20130710092255.0240a36d@notabene.brown> <20130710022735.GI8281@fieldses.org> <51DD9AD5.1030508@gmail.com> <51DD9C5A.3000505@candelatech.com> <20130715143527.4eca7283@notabene.brown>
In-Reply-To: <20130715143527.4eca7283@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/14/2013 09:35 PM, NeilBrown wrote:
> On Wed, 10 Jul 2013 10:39:38 -0700 Ben Greear <greearb@candelatech.com> wrote:
>
>> On 07/10/2013 10:33 AM, Dean wrote:
>>>   > This could significantly limit the amount of parallelism that can be achieved for a single TCP connection (and given that the
>>>   > Linux client strongly prefers a single connection now, this could become more of an issue).
>>>
>>> I understand the simplicity in using a single tcp connection, but performance-wise it is definitely not the way to go on WAN links. When even a miniscule amount
>>> of packet loss is added to the link (<0.001% packet loss), the tcp buffer collapses and performance drops significantly (especially on 10GigE WAN links).  I
>>> think new TCP algorithms could help the problem somewhat, but nothing available today makes much of a difference vs. cubic.
>>>
>>> Using multiple tcp connections allows better saturation of the link, since when packet loss occurs on a stream, the other streams can fill the void.  Today, the
>>> only solution is to scale up the number of physical clients, which has high coordination overhead, or use a wan accelerator such as Bitspeed or Riverbed (which
>>> comes with its own issues such as extra hardware, cost, etc).
>>
>> I have a set of patches that allows one to do multiple unique mounts to the same server from a single
>> client, but the patches are for the client side, so it would not help
>> non-Linux clients.  And, the patches were rejected for upstream as not being
>> useful.  But, if you are interested in such, please let me know and I can point
>> you to them...
>
> Yes please!


I haven't ported these forward to 3.10 yet, but you can find my 3.9 tree
here:

http://dmz2.candelatech.com/git/gitweb.cgi?p=linux-3.9.dev.y/.git;a=summary

There's a bunch of other patches, but the nfs related ones are all in a row
and the patches are rebased, so you can probably pull them out w/out
too much difficulty.  The patches introduce a bug where it fails to compile
w/out NFS 4.1 defined..I haven't bothered to fix it yet but it's probably
simple..or just compile with NFS 4.1 as I do.

Older trees found here, but we don't bother back-porting many patches,
so I'd use the latest if you can.

http://dmz2.candelatech.com/git/gitweb.cgi

And, you'll need a patched mount.nfs:

https://github.com/greearb/nfs-utils-ct

I hope to get started on porting these to 3.10 later this week..  If
there is any interest in this patch series or something like it going
upstream (there wasn't in the past, I've no good reason to think that
has changed), let me know and I will clean them up and post them to
the mailing list again...

If you search for greearb@candelatech.com and 'bind to local' you
can find previous threads in the mailing list archives...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

