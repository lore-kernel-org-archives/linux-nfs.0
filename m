Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:35216 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754963AbcLBAu2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 19:50:28 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: NeilBrown <neilb@suse.com>
CC: Joachim Banzhaf <joachim.banzhaf@googlemail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: rpcbind allowed port range on linux
Date: Fri, 2 Dec 2016 00:50:15 +0000
Message-ID: <BD0BB270-C6F4-4129-8D21-A3E9A6970459@primarydata.com>
References: <CABW3MLd5Bo-xBtLqtB4e-pD2hCYAuRaBBsqBFTiws5-HohjPTw@mail.gmail.com>
 <87h96n6vbl.fsf@notabene.neil.brown.name>
In-Reply-To: <87h96n6vbl.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 1, 2016, at 19:14, NeilBrown <neilb@suse.com> wrote:
>=20
> On Fri, Dec 02 2016, Joachim Banzhaf wrote:
>=20
>> Hi list,
>>=20
>> my problem is, rpcbind gave a tcp port to nlockmgr where I assumed
>> this port is reserved.
>=20
> That isn't how it works. rpcbind doesn't give ports to anyone.
>=20
> lockd chooses a port, and asks rpcbind to register it against the
> nlockmgr service.
> If lockd is choosing a port that you don't want it to, you need to
> get lockd to change its behavior.
>=20
> One way is to explicitly tell lockd what port to use.  The "--nlm-port"
> option to rpc.statd can do this.
>=20
> By default, a number will be chosen from the range given in
>  /proc/sys/net/ipv4/ip_local_port_range=20
>=20
> You can change that range, and that will affect all sockets which don't
> ask for an explicit port.

Alternatively, you can just pin the port using the kernel parameters interf=
aces:

http://lxr.free-electrons.com/source/Documentation/kernel-parameters.txt#L2=
036

>=20
> NeilBrown
>=20
>=20
>>=20
>> Now, I didn't find the spec that says which ports rpcbind is allowed
>> to use, but I thought it is the ephemeral ports, on linux defined with
>> the range in kernel configuration net.ipv4.ip_local_reserved_ports
>> minus exclusions from net.ipv4.ip_local_reserved_ports.
>>=20
>> So, my questions are
>> 1) Is my assumption about allowed ports correct?
>> 2) If not: how can I define that range?
>> 3) If yes: was there a fix for that since my rather old SLES 12
>> version rpcbind-0.2.1_rc4 (kernel 3.12.55)? I didn't find something
>> obvious to me in the changelog.
>>=20
>> Bonus question: would it have been safe/possible to free up the port,
>> e.g. with rpcbind -d? I only found out about that option after a
>> reboot...
>>=20
>> BR,
>> Joachim
>>=20
>> (please keep me in cc)
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

