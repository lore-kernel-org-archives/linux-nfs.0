Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:57954 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464Ab1JUU6W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2011 16:58:22 -0400
Received: by vws1 with SMTP id 1so3297666vws.19
        for <linux-nfs@vger.kernel.org>; Fri, 21 Oct 2011 13:58:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111021221001.71628099@neminis.intra.loos.site>
References: <20111021012327.612839b5@neminis.loos.site>
	<CAKnQG+d66Driv-D7fTeyh=MP4iNqpTzjXyFEiLE34E3YV2KG_g@mail.gmail.com>
	<20111021221001.71628099@neminis.intra.loos.site>
Date: Fri, 21 Oct 2011 16:58:20 -0400
Message-ID: <CAKnQG+d6V4sjY8i0-kLvUPGLgY+m8R3+yTqzdMaF3rsfWq2RYQ@mail.gmail.com>
Subject: Re: sec=krb5 mounts never return
From: Kevin Coffman <kwc@umich.edu>
To: Arno Schuring <aelschuring@hotmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 21, 2011 at 4:10 PM, Arno Schuring <aelschuring@hotmail.com> wrote:
> Hi Kevin,
>
> thanks for your reply. Attached is all the information I have been able
> to gather thus far (kernel and daemon logs).
>
> Kevin Coffman (kwc@umich.edu on 2011-10-21 10:33 -0400):
>> On Thu, Oct 20, 2011 at 7:23 PM, Arno Schuring
>> <aelschuring@hotmail.com> wrote:
>> >
>> > I've been running a succesful NFS4 setup at home for a year now, but
>> > incorporating krb5 security has so far proven fruitless. I believe
>> > the Kerberos side of the equation is no longer causing problems; it
>> > is used for user authentication too, and nfs security contexts seem
>> > to work properly. As said above, the mount request for any Kerberos
>> > mount gets halted somewhere in flight:
> [..]
>> > [600472.772226] nfsd: connect from 172.22.21.8, port=46257
>> > [600472.772300] svc: svc_setup_socket created deda1a00 (inet
>> > df948900) [600473.431966] svc_recv: found XPT_CLOSE
>> > [600473.431982] svc: svc_delete_xprt(deda1a00)
>> > [600473.432114] svc: transport deda1a00 is dead, not enqueued
>> >
>>
>> You should be seeing syslog messages if not, but I'll ask anyway.
>> You've got rpc.gssd configured and running on the client, and if this
>> is a linux server, rpc.svcgssd configured and running on the server.
>> ("Configured" more or less means you've got a keytab.)  If they are
>> running, what does their output look like?  (Perhaps using "-vvv" to
>> get detailed output.)
>
> In this case I'm trying with a local mount, so client==server. The gssd
> logs invariably end with the following lines:
> rpc.gssd[26133]: creating context with server nfs@genie.loos.site
> rpc.gssd[28189]: DEBUG: serialize_krb5_ctx: lucid version!
> rpc.gssd[28189]: prepare_krb5_rfc1964_buffer: serializing keys with
> enctype 4 and length 8
> rpc.gssd[28189]: doing downcall
> [ then nothing until I kill the mount process ]
>
> In the svcgssd logs, nothing stands out to me. It all appears proper
> to the untrained eye:
>
> rpc.svcgssd[26188]: handling null request
> rpc.svcgssd[26188]: sname = nfs/genie.loos.site@LOOS.SITE
> rpc.svcgssd[26188]: libnfsidmap: using (default) domain: loos.site
> rpc.svcgssd[26188]: DEBUG: serialize_krb5_ctx: lucid version!
> rpc.svcgssd[26188]: prepare_krb5_rfc1964_buffer: serializing keys with
> enctype 4 and length 8
> rpc.svcgssd[26188]: doing downcall
> rpc.svcgssd[26188]: mech: krb5, hndl len: 4, ctx len 85, timeout:
> 1319183270 (35999 from now), clnt: nfs@genie.loos.site, uid: -1, gid:
> -1, num aux grps: 0:
> rpc.svcgssd[26188]: sending null reply
> rpc.svcgssd[26188]: finished handling null request
>
>
> Regards,
> Arno

The userland/daemon stuff all looks fine to me.  I'm not as familiar
with the kernel logs.  I believe the following kernel messages are
from the ^C:

Oct 20 23:48:18 genie kernel: [600500.662524] RPC:   437 return -512,
status -512
Oct 20 23:48:18 genie kernel: [600500.662539] RPC:   437 release task
Oct 20 23:48:18 genie kernel: [600500.662558] RPC:       freeing
buffer of size 3712 at d6915000
Oct 20 23:48:18 genie kernel: [600500.662578] RPC:   437 release
request d6911000
Oct 20 23:48:18 genie kernel: [600500.662594] RPC:
wake_up_next(c3966234 "xprt_backlog")
Oct 20 23:48:18 genie kernel: [600500.662613] RPC:   437 releasing
RPCSEC_GSS cred df1f9300
Oct 20 23:48:18 genie kernel: [600500.662631] RPC:
rpc_release_client(de639e00)
Oct 20 23:48:18 genie kernel: [600500.662648] RPC:   437 freeing task
Oct 20 23:48:18 genie kernel: [600500.662664] nfs4_get_root: getroot error = 512

I don't see anything obviously wrong.

K.C.
