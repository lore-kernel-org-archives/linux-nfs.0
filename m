Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:46050 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640Ab0JAWlt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 18:41:49 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: persistent, quasi-random -ESTALE at mount time
References: <87mxra6duq.fsf@spindle.srvr.nix>
	<20100922155235.GE15560@fieldses.org>
	<8762xwqijb.fsf@spindle.srvr.nix> <20101001220018.GE1472@fieldses.org>
From: Nix <nix@esperi.org.uk>
Date: Fri, 01 Oct 2010 23:41:42 +0100
In-Reply-To: <20101001220018.GE1472@fieldses.org> (J. Bruce Fields's message of "Fri, 1 Oct 2010 18:00:18 -0400")
Message-ID: <87zkux5ye1.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 1 Oct 2010, J. Bruce Fields spake thusly:

> On Thu, Sep 23, 2010 at 10:03:36PM +0100, Nix wrote:
>> I'll say.
>
> Sorry for the slow response; have you figured out anything more?

Not yet. I try not to reboot the server except at weekends... I'll
try to hook things up with a more rebootable machine as an NFS
server (perhaps via qemu) so I can look into this without so much
disruption.

>> I flipped RPC debug on and rebooted the client next. The server said:
>> 
>> Sep 23 21:33:15 spindle warning: [  127.385537] RPC:       Want update, refage=120, age=0
>> Sep 23 21:33:15 spindle warning: [  127.536779] RPC:       Want update, refage=120, age=0
>> [repeated 40 times]
>> 
>> When it connected, the server said
>> 
>> Sep 23 21:34:23 spindle warning: [  195.696257] RPC:       Want update, refage=120, age=68
> ...
>> Sep 23 21:34:38 spindle warning: [  210.766205] RPC:       Want update, refage=120, age=83
>> 
>> Now, the rpc/*/content files had grown again, and even the -ESTALEd
>> filesystems, like /home/.spindle.srvr.nix, are represented once more:
>
> I'm a little confused.  Are you saying that in this case the client did
> get ESTALE's?

Yes. Bizarre, isn't it? -ESTALE, but here the filesystems are! Note that
if you try to reboot again, you still get -ESTALE: only restarting
rpc.mountd seems to fix it.

>> I restarted rpc.mountd and the client, so it mounted correctly. Here's a
>
> And then here the problems was cleared and you didn't see any more of
> them?

Yes, until the server got rebooted again.

I mean, yes, we can work around it by killing rpc.mountd and restarting
it as soon as the server has booted, but, well, yuck, no thanks, too
much of a kludge. I'll have a concentrated hunt for the bug soon (once I
can reproduce it without rebooting the single largest machine I have
root on!)
