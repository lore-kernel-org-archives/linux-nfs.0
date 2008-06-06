From: Ricardo Labiaga <labiaga@yahoo.com>
Subject: Re: [NFS] I/O Errors with hard mounts
Date: Thu, 5 Jun 2008 18:00:34 -0700 (PDT)
Message-ID: <667549.96319.qm@web31407.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
To: David Konerding <dakoner@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43825 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752298AbYFFBBM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2008 21:01:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K4QKL-0007uY-22
	for linux-nfs@vger.kernel.org; Fri, 06 Jun 2008 11:01:09 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

You have a=A0significant number of dropped connections, as indicated by=
 the high EAGAIN count.
I wouldn't be surprised if the 2.6.16 kernel isn't handling the reconne=
ction correctly and propagating
EIO to the application.=A0 There's=A0been a fair amount of client side =
work in the RPC=A0reconnection=20
code=A0recently .=A0 Can you try with a recent kernel?
A network trace and rpcdebug output would be invaluable when you're abl=
e to reproduce this.
- ricardo
On Wed, Jun 4, 2008 at 3:45 PM, Ricardo Labiaga <labiaga@yahoo.com> wro=
te:
>> Does /var/log/messages show any errors around the same time?=A0=20
>> In addition to the network trace and rpcdebug on the client, take a =
look at "nfsstat -d" on the filer.=20
>>=A0Is the filer dropping the connection?=A0 Look for "dropped with EA=
GAIN" or "dropped from vol offline"=20
>> in the output.=A0 This will help narrow down the problem.
> So, sometimes when somebody deletes a lot of data (like the problem w=
e
> just observed),
> the deleting host, and often other hosts, do report=A0 'filer not
> responding' in the logs.
> However, operations that aren't happening in the delete dir, tend to
> work just fine (for example, iozone could be running and doing pretty
> well)).=A0 Further, the most recent time this happened, the host didn=
't
> report filer not responding.
>
> This is the only EAGAN reference I see:
>
> assist queue (queued, split mbufs, drop for EAGAIN) =3D (0, 64478612,=
 94340)
>
> Dave


     =20

-----------------------------------------------------------------------=
--
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

