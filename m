Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43865 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755433AbdGSPuc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 11:50:32 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170719151146.GE5628@stefanha-x1.localdomain>
Date: Wed, 19 Jul 2017 17:50:19 +0200
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Message-Id: <88747651-12F6-47A0-AC31-5E3E05F07988@oracle.com>
References: <20170630132120.31578-1-stefanha@redhat.com> <20170630132120.31578-6-stefanha@redhat.com> <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com> <20170719151146.GE5628@stefanha-x1.localdomain>
To: Stefan Hajnoczi <stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 19, 2017, at 17:11, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> 
> On Fri, Jun 30, 2017 at 11:52:15AM -0400, Chuck Lever wrote:
>>> On Jun 30, 2017, at 9:21 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
>>> 
>>> Neither libtirpc nor getprotobyname(3) know about AF_VSOCK.
>> 
>> Why?
>> 
>> Basically you are building a lot of specialized
>> awareness in applications and leaving the
>> network layer alone. That seems backwards to me.
> 
> Yes.  I posted glibc patches but there were concerns that getaddrinfo(3)
> is IPv4/IPv6 only and applications need to be ported to AF_VSOCK anyway,
> so there's not much to gain by adding it:
> https://cygwin.com/ml/libc-alpha/2016-10/msg00126.html
> 
>>> For similar
>>> reasons as for "rdma"/"rmda6", translate "vsock" manually in getport.c.
>> 
>> rdma/rdma6 are specified by standards, and appear
>> in the IANA Network Identifiers database:
>> 
>> https://www.iana.org/assignments/rpc-netids/rpc-netids.xhtml
>> 
>> Is there a standard netid for vsock? If not,
>> there needs to be some discussion with the nfsv4
>> Working Group to get this worked out.
>> 
>> Because AF_VSOCK is an address family and the RPC
>> framing is the same as TCP, the netid should be
>> something like "tcpv" and not "vsock". I've
>> complained about this before and there has been
>> no response of any kind.
>> 
>> I'll note that rdma/rdma6 do not use alternate
>> address families: an IP address is specified and
>> mapped to a GUID by the underlying transport.
>> We purposely did not expose GUIDs to NFS, which
>> is based on AF_INET/AF_INET6.
>> 
>> rdma co-exists with IP. vsock doesn't have this
>> fallback.
> 
> Thanks for explaining the tcp + rdma relationship, that makes sense.
> 
> There is no standard netid for vsock yet.
> 
> Sorry I didn't ask about "tcpv" when you originally proposed it, I lost
> track of that discussion.  You said:
> 
>  If this really is just TCP on a new address family, then "tcpv"
>  is more in line with previous work, and you can get away with
>  just an IANA action for a new netid, since RPC-over-TCP is
>  already specified.
> 
> Does "just TCP" mean a "connection-oriented, stream-oriented transport
> using RFC 1831 Record Marking"?  Or does "TCP" have any other
> attributes?
> 
> NFS over AF_VSOCK definitely is "connection-oriented, stream-oriented
> transport using RFC 1831 Record Marking".  I'm just not sure whether
> there are any other assumptions beyond this that AF_VSOCK might not meet
> because it isn't IP and has 32-bit port numbers.

Right, it is TCP in the sense that it is connection-oriented
and so on. It looks like a stream socket to the RPC client.
TI-RPC calls this "tpi_cots_ord".

But it isn't TCP in the sense that you aren't moving TCP
segments over the link.

I think the "IP / 32-bit ports" is handled entirely within
the address variant that your link is using.

>> It might be a better approach to use well-known
>> (say, link-local or loopback) addresses and let
>> the underlying network layer figure it out.
>> 
>> Then hide all this stuff with DNS and let the
>> client mount the server by hostname and use
>> normal sockaddr's and "proto=tcp". Then you don't
>> need _any_ application layer changes.
>> 
>> Without hostnames, how does a client pick a
>> Kerberos service principal for the server?
> 
> I'm not sure Kerberos would be used with AF_VSOCK.  The hypervisor knows
> about the VMs, addresses cannot be spoofed, and VMs can only communicate
> with the hypervisor.  This leads to a simple trust relationship.

The clients can be exploited if they are exposed in any
way to remote users. Having at least sec=krb5 might be
a way to block attackers from accessing data on the NFS
server from a compromised client.

In any event, NFSv4 will need ID mapping. Do you have a
sense of how the server and clients will determine their
NFSv4 ID mapping domain name? How will the server and
client user ID databases be kept in synchrony? You might
have some issues if there is a "cel" in multiple guests
that are actually different users.


>> Does rpcbind implement "vsock" netids?
> 
> I have not modified rpcbind.  My understanding is that rpcbind isn't
> required for NFSv4.  Since this is a new transport there is no plan for
> it to run old protocol versions.
> 
>> Does the NFSv4.0 client advertise "vsock" in
>> SETCLIENTID, and provide a "vsock" callback
>> service?
> 
> The kernel patches implement backchannel support although I haven't
> exercised it.
> 
>>> It is now possible to mount a file system from the host (hypervisor)
>>> over AF_VSOCK like this:
>>> 
>>> (guest)$ mount.nfs 2:/export /mnt -v -o clientaddr=3,proto=vsock
>>> 
>>> The VM's cid address is 3 and the hypervisor is 2.
>> 
>> The mount command is supposed to supply "clientaddr"
>> automatically. This mount option is exposed only for
>> debugging purposes or very special cases (like
>> disabling NFSv4 callback operations).
>> 
>> I mean the whole point of this exercise is to get
>> rid of network configuration, but here you're
>> adding the need to additionally specify both the
>> proto option and the clientaddr option to get this
>> to work. Seems like that isn't zero-configuration
>> at all.
> 
> Thanks for pointing this out.  Will fix in v2, there should be no need
> to manually specify the client address, this is a remnant from early
> development.
> 
>> Wouldn't it be nicer if it worked like this:
>> 
>> (guest)$ cat /etc/hosts
>> 129.0.0.2  localhyper
>> (guest)$ mount.nfs localhyper:/export /mnt
>> 
>> And the result was a working NFS mount of the
>> local hypervisor, using whatever NFS version the
>> two both support, with no changes needed to the
>> NFS implementation or the understanding of the
>> system administrator?
> 
> This is an interesting idea, thanks!  It would be neat to have AF_INET
> access over the loopback interface on both guest and host.

--
Chuck Lever



