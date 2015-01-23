Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:3495 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820AbbAWWS6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2015 17:18:58 -0500
Date: Fri, 23 Jan 2015 17:18:50 -0500 (EST)
From: "Matt W. Benjamin" <matt@cohortfs.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <419322449.95.1422051530785.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1321655997.90.1422051197579.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: NFSv4.1 backchannel for RDMA
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

----- "Chuck Lever" <chuck.lever@oracle.com> wrote:

> Hi-
> 
> I’d like to restart the discussion in this thread:
> 
>   http://marc.info/?l=linux-nfs&m=141348840527766&w=2

Thank you for doing this.

> 
> It seems to me there are two main points:
> 
> 1.  Is bi-directional RPC on RPC/RDMA transports desirable?
> 
> 2.  Is a secondary backchannel-only transport adequate and reliable?
> 
> I’ll try to summarize the current thinking.
> 
> 
> Question 1:
> 
> The main reason to plumb bi-RPC into RPC/RDMA is that no changes to
> the NFSv4.1 client upper layers would be needed. I think we also
> agree that:
> 
>  - There is no performance benefit. CB operations typically lack
>    significant payload, are infrequent, and can be long-running.
> 
>  - There is no need to penetrate firewalls. Firewall compatibility
>    was the original motivation for single-transport NFSv4.1
>    operation. Firewalls are not typically found in RDMA-native
>    environments.
> 
>  - There is no requirement in RFC 5661 for the forward channel
>    transport to support bi-directional RPC. Backchannel capability
>    is detected via the CREATE_SESSION operation.
> 
>  - TCP connectivity will always be available wherever NFS/RDMA is
>    deployed. For NFS/RDMA operation, IP address to GUID mapping must
>    be provided by the transport layer, below RPC/RDMA.
> 
>  - To handle large payloads (possibly required by certain pNFS
>    CB operations), an NFSv4.1 client would need to handle
>    RDMA_NOMSG type calls over the backchannel. This would require
>    the client to perform RDMA READ and WRITE operations against the
>    server (the opposite of what happens in the forward channel).
> 
> There is some interest in prototyping an RPC/RDMA transport that is
> capable of bi-directional RPC. A prototype would help us determine
> whether there are subtle problems that make bi-RPC impossible for
> RPC/RDMA, and identify any spec gaps that need to be addressed.
> Because of the development cost and lack of perceptible benefits, a
> prototype has not been attempted so far.
> 
> Would it be productive for a bi-capable RPC/RDMA transport prototype
> to be pursued in Linux?

As the implementer of backchannel RPC communications for TCP in Ganesha, which initially lacked support for bi-directional RPC communications over TCP, I found myself in the precisely analogous circumstance of being able to trivially adjust a Linux client to create a "side-car" TCP backchannel for a TCP fore-channel, and associate it using the BIND_CONN_TO_SESSION operation.  I found it unfortunate that the Linux client maintainers were unwilling to consider any possibility to interoperate with a server using a separate backchannel association, not only as a matter of implementation convenience, but also in anticipation of workloads which might benefit from trunking in general, including potentially improved latency for backchannel operations.  Nevertheless, bi-directional RPC communication over TCP is (setting aside trunking) more natural, more compact, and more symmetrical--I completely prefer it in general.  NFSv4.1 is well served by it, and in retrospect, it is clear tha!
 t in this circumstance, the requirement to interoperate with the Linux client benefited Ganesha and its users.

As a long-time OpenAFS developer involved with widening of the AFS callback channel to support new operations, I find sub-point #1 above ("CB operations typically lack significant payload, are infrequent, and can be long-running") unpersuasive, because circular.  The NFSv4 backchannel has, #1, been underutilized historically, but, #2, the situation has substantially changed due to widespread deployment--just beginning now--of both NFSv4.1 delegations and NFSv4.1 pNFS layouts, both of which use the backchannel for invalidation.

As the implementer of RDMA communications in the Ceph protocols (using the Accelio abstraction above OFED interfaces), I find it pretty difficult to imagine not taking full advantage of bi-directional communications over RDMA, as we do in Accelio.  Bi-directional operation appears to be the default style of operation in other RDMA protocols, as well.  That's not an argument against having flexible trunking support available in both the NFSv4.1 forechannel and backhcannel--I think we should.  I do think that "we don't need it" is, in the first instance, special pleading from the viewpoint of avoiding cost of implementation, and in the second instance, a circular argument which, taken to its logical conclusion, weakens the current and future utility of NFSv4.1.

In fine, a prototype implementation of bi-directional RPC over RDMA certainly seems well motivated.

> 
> 
> Question 2:
> 
> The Solaris client and server already implement a sidecar TCP
> backchannel for NFSv4.1. This is something that can be tested.
> Further, I think we agree that:
> 
>  - Servers are required to support a separate backchannel and
>    forward channel transport, and both sides can detect what is
>    supported with CREATE_SESSION. However, there are no existing
>    implementations that have deployed this kind of logic widely.
>  
>  - The addition of a separate backchannel-only connection is
>    considered session trunking, which is regarded as potentially
>    hazardous. We haven’t identified exactly what the  hazards might
>    be when the second connection handles only backchannel activity.
> 
>  - Although there are few or no server changes required to support
>    a secondary backchannel, clients would have to be modified to
>    establish this connection when one or both sides do not support
>    a backchannel on the main transport and the server asserts the
>    SEQ4_STATUS_CB_PATH_DOWN flag.
> 
>  - We have some confidence that creation of the second backchannel-
>    only connection followed by BIND_CONN_TO_SESSION appears to be
>    adequate and robust. However, the salient recovery edge conditions
>    when a secondary backchannel transport is being used still need to
>    be identified.
> 
> What further investigation is needed to be confident that the sidecar
> solution is adequate and appropriate?

When I prototyped having a Linux client interoperate with a old-style Ganesha server, it
initially appeared obvious that the client attempt to initiate a dedicated backchannel to
the server, if the server marked the initial session as ineligible for backchannel
communications, and associate it using BIND_CONN_TO_SESSION.

This appeared fully robust, and worked, but of course, required cooperation from the client.

Regards,

Matt

> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Matt Benjamin
CohortFS, LLC.
315 West Huron Street, Suite 140A
Ann Arbor, Michigan 48103

http://cohortfs.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
