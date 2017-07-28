Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:38155 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdG1Afd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jul 2017 20:35:33 -0400
Received: by mail-pg0-f45.google.com with SMTP id k190so38724659pgk.5
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 17:35:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com>
 <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
From: Matt Benjamin <mbenjami@redhat.com>
Date: Thu, 27 Jul 2017 20:35:32 -0400
Message-ID: <CAKOnarkh26_DOCwaeacSwxqa2WE3vS-CkzvYwf9DNewe+thO6g@mail.gmail.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Fri, Jun 30, 2017 at 11:52 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi Stefan-

>
> Is there a standard netid for vsock? If not,
> there needs to be some discussion with the nfsv4
> Working Group to get this worked out.
>
> Because AF_VSOCK is an address family and the RPC
> framing is the same as TCP, the netid should be
> something like "tcpv" and not "vsock". I've
> complained about this before and there has been
> no response of any kind.

the onc record marking is just the length/end-of-transmission bit, and
the bytes.  something is being borrowed, but it isn't tcp

>
> I'll note that rdma/rdma6 do not use alternate
> address families: an IP address is specified and
> mapped to a GUID by the underlying transport.
> We purposely did not expose GUIDs to NFS, which
> is based on AF_INET/AF_INET6.

but, as you state, vsock is an address family.

>
> rdma co-exists with IP. vsock doesn't have this
> fallback.

doesn't appear to be needed.

>
> It might be a better approach to use well-known
> (say, link-local or loopback) addresses and let
> the underlying network layer figure it out.
>
> Then hide all this stuff with DNS and let the
> client mount the server by hostname and use
> normal sockaddr's and "proto=tcp". Then you don't
> need _any_ application layer changes.

the changes in nfs-ganesha and ntirpc along these lines were rather trivial.

>
> Without hostnames, how does a client pick a
> Kerberos service principal for the server?

no mechanism has been proposed

>
> Does rpcbind implement "vsock" netids?

are they needed?

>
> Does the NFSv4.0 client advertise "vsock" in
> SETCLIENTID, and provide a "vsock" callback
> service?

It should at least do the latter;  does it need to advertise
differently in SETCLIENTID?

>
>
>> It is now possible to mount a file system from the host (hypervisor)
>> over AF_VSOCK like this:
>>
>>  (guest)$ mount.nfs 2:/export /mnt -v -o clientaddr=3,proto=vsock
>>
>> The VM's cid address is 3 and the hypervisor is 2.
>
> The mount command is supposed to supply "clientaddr"
> automatically. This mount option is exposed only for
> debugging purposes or very special cases (like
> disabling NFSv4 callback operations).
>
> I mean the whole point of this exercise is to get
> rid of network configuration, but here you're
> adding the need to additionally specify both the
> proto option and the clientaddr option to get this
> to work. Seems like that isn't zero-configuration
> at all.

This whole line of criticism seems to me kind of off-kilter.  The
concept of cross-vm pipes appears pretty classical, and one can see
why it might not need to follow Internet conventions.

I'll give you that I never found the zeroconf or security rationales
as compelling--which is to say, I wouldn't restrict vsock to
guest-host communications, except by policy.

>
> Wouldn't it be nicer if it worked like this:
>
> (guest)$ cat /etc/hosts
> 129.0.0.2  localhyper
> (guest)$ mount.nfs localhyper:/export /mnt
>
> And the result was a working NFS mount of the
> local hypervisor, using whatever NFS version the
> two both support, with no changes needed to the
> NFS implementation or the understanding of the
> system administrator?
>
>

not clear;  I can understand 2:/export pretty easily, and I don't
think any minds would be blown if "localhyper:" effected 2:.

>
> --
> Chuck Lever
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Matt
