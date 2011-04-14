Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:38502
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754472Ab1DNX0w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2011 19:26:52 -0400
Date: Fri, 15 Apr 2011 01:20:04 +0200
From: Michael Guntsche <mike@it-loops.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Subject: [BUG] sec=krb5 mount problem with nfs-utils 1.2.3 on client side
Message-ID: <20110415010913@it-loops.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I recently updated my nfs clients and server to the new nfs-utls Version
1.2.3 and then also tested a sec=krb5 mount via nfs4 again. For some reason
the mount failed and I got the following message on the server.

rpc.svcgssd output:
===================
entering poll
leaving poll
handling null request
sname = nfs/zaphod.comsick.at@COMSICK.AT
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc4121_buffer: protocol 1
prepare_krb5_rfc4121_buffer: serializing key with enctype 18 and size 32
doing downcall
mech: krb5, hndl len: 4, ctx len 52, timeout: 1302858643 (35979 from
now), clnt: nfs@zaphod.comsick.at, uid: -1, gid: -1, num aux grps: 0:
: qword_eol: fflush failed: errno 22 (Invalid argument)
WARNING: error writing to downcall channel
/proc/net/rpc/auth.rpcsec.context/channel: Invalid argument
sending null reply
finished handling null request
<repeated 4 times>

Since it worked before I downgraded the versions on both the client and
the server to see when it started working again.

Server with 1.2.3 and  client with 1.2.2 did the trick

rpc.svcgssd output:
===================
entering poll
leaving poll
handling null request
sname = nfs/zaphod.comsick.at@COMSICK.AT
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length
8
doing downcall
mech: krb5, hndl len: 4, ctx len 85, timeout: 1302858893 (36000 from
now), clnt: nfs@zaphod.comsick.at, uid: -1, gid: -1, num aux grps: 0:
sending null reply
finished handling null request
entering poll

So apparently with 1.2.2 on the client side a different enctype is
select. I searched in the archives and saw that this problem was already
known but I did not see any fixes. Both client and server have
aes_generic enabled and loaded I also made sure that the correct keys on
the kerberos side are available.

Valid starting     Expires            Service principal 04/15/11
01:14:53  04/15/11 11:14:53  krbtgt/COMSICK.AT@COMSICK.AT renew until
04/16/11 01:14:53, Etype (skey, tkt): des3-cbc-sha1, des3-cbc-sha1
04/15/11 01:14:53  04/15/11 11:14:53  nfs/gibson.comsick.at@COMSICK.AT
renew until 04/16/11 01:14:53, Etype (skey, tkt): des-cbc-crc,
aes256-cts-hmac-sha1-96 

So right now I am little bit stumped 

* why another enctype is used
* why it does not succeed with the new enctype

Both machines are running kernel 2.6.38 on debian sid with the latest
Kerberos 1.9

If you need more information please tell me.

Kind regards,
Michael Guntsche


