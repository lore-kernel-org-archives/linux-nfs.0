Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27152 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933004AbdKPUxQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Nov 2017 15:53:16 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 08/14] SUNRPC: add AF_VSOCK support to svc_xprt.c
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20171116152502.GG29106@stefanha-x1.localdomain>
Date: Thu, 16 Nov 2017 15:53:04 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Bruce Fields <bfields@fieldses.org>
Message-Id: <A8EC5B49-872F-4D60-835C-5D1C2C04E362@oracle.com>
References: <20170630132352.32133-1-stefanha@redhat.com> <20170630132352.32133-9-stefanha@redhat.com> <1509459038.4553.26.camel@redhat.com> <20171107133111.GK6809@stefanha-x1.localdomain> <1510063286.4518.34.camel@redhat.com> <20171116152502.GG29106@stefanha-x1.localdomain>
To: Stefan Hajnoczi <stefanha@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 16, 2017, at 10:25 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> 
> On Tue, Nov 07, 2017 at 09:01:26AM -0500, Jeff Layton wrote:
>> On Tue, 2017-11-07 at 13:31 +0000, Stefan Hajnoczi wrote:
>>> On Tue, Oct 31, 2017 at 10:10:38AM -0400, Jeff Layton wrote:
>>>> On Fri, 2017-06-30 at 14:23 +0100, Stefan Hajnoczi wrote:
>>>>> @@ -595,6 +609,10 @@ int svc_port_is_privileged(struct sockaddr *sin)
>>>>> 	case AF_INET6:
>>>>> 		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
>>>>> 			< PROT_SOCK;
>>>>> +	case AF_VSOCK:
>>>>> +		return ((struct sockaddr_vm *)sin)->svm_port <=
>>>>> +			LAST_RESERVED_PORT;
>>>>> +
>>>>> 	default:
>>>>> 		return 0;
>>>>> 	}
>>>> 
>>>> Does vsock even have the concept of a privileged port? I would imagine
>>>> that root in a guest VM would carry no particular significance from an
>>>> export security standpoint
>>>> 
>>>> Since you're defining a new transport here, it might be nice write the
>>>> RFCs to avoid that distinction, if possible.
>>>> 
>>>> Note that RDMA just has svc_port_is_privileged always return 1.
>>> 
>>> AF_VSOCK has the same 0-1023 privileged port range as TCP.
>>> 
>> 
>> But why? And, given that you have 32-bits for a port with AF_VSOCK vs
>> the 16 bits on an AF_INET/AF_INET6, why is the range so pitifully small?
>> 
>> Reserved ports are a bit of a dinosaur holdover from when being root on
>> a machine on the Internet meant something. With v4.1 it's much less of
>> an issue, but in the "olden days", reserved port exhaustion could be a
>> real problem.
>> 
>> Mandating low ports can also be a problem in other way. Some well known
>> services use ports in the ephemeral range, and if your service starts
>> late and someone else has taken the port for an ephemeral one, you're
>> out of luck.
>> 
>> I think we have to ask ourselves:
>> 
>> Should the ability to open a low port inside of a VM carry any
>> significance at all to an RPC server? I'd suggest not, and I think it'd
>> be good to word the RFC to make that explicitly clear.
> 
> AF_VSOCK has had the reserved port range since it was first merged in
> 2013.  That's before my time but I do see some use for identifying
> connections coming from privileged processes.
> 
> Given that TCP has the same privileged port range, is there any reason
> why AF_VSOCK would be any worse off than TCP for having it?

I agree with Jeff that we need to think carefully about this.

I don't especially care for the privileged port check, but:

In this case, you are inventing an RPC transport that makes
it impossible to use strong security (ie, RPCSEC_GSS). We
should be careful about removing the check because only
AUTH_NULL and AUTH_UNIX security can be used in this kind
of deployment.

Privileged ports are easy to spoof if there is an opportunity
for a MitM attack to alter the port number of RPCs in transit.
With VSOCK there may be no such opportunity, thus privileged
ports might provide an adequate level of security here. I
make that claim with no deep experience of VSOCK environments.

When writing the VSOCK-related RFCs, you will need to provide
a very clear and concise rationale to the IESG for purposely
not supporting the use of RPCSEC_GSS. It will start with "well,
these RPCs do not flow on open networks and are thus not
subject to MitM attacks"; then proceed to careful discussion of
how the server will guard against rogue users on guests, and
assumptions about the trust relationship between the guests
and the host. You will have to make AUTH_UNIX into a defensible
deployment choice, and port privilege might be a part of that.

Note also that the NFSv4 standards require that implementations
can support RPCSEC_GSS. NFSv4 on VSOCK cannot. Something will
have to be done about that.


--
Chuck Lever



