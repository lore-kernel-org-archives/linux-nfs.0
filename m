Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38108 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbbAWWoS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2015 17:44:18 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so84159igb.5
        for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 14:44:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <E4A8B62E-BCFC-497F-B134-ECD90F232804@oracle.com>
References: <E4A8B62E-BCFC-497F-B134-ECD90F232804@oracle.com>
Date: Fri, 23 Jan 2015 17:44:17 -0500
Message-ID: <CAABAsM4y_f889vvDthy52gdr_=8Rf6BfwN5_A15wdRwMg_HP=w@mail.gmail.com>
Subject: Re: NFSv4.1 backchannel for RDMA
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 23, 2015 at 4:00 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi-
>
> I’d like to restart the discussion in this thread:
>
>   http://marc.info/?l=linux-nfs&m=141348840527766&w=2
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

No. Firewalls were the motivation for having the client establish both
the forward and backward channel.

A few of my main motivations for a single transport NFS are:
- Simplify connection management
    - Ensure that the front and back channel are both subject to the
same routing/firewall conditions
    - Simplify detection of back channel connection breakage
- Manage the reserved/privileged ports scarcity issue that continues
to plague AUTH_SYS.

>  - There is no requirement in RFC 5661 for the forward channel
>    transport to support bi-directional RPC. Backchannel capability
>    is detected via the CREATE_SESSION operation.

There is no requirement in RFC5661 for a backchannel at all unless you
want to support pNFS or have strong opinions about wanting
delegations.

>  - TCP connectivity will always be available wherever NFS/RDMA is
>    deployed. For NFS/RDMA operation, IP address to GUID mapping must
>    be provided by the transport layer, below RPC/RDMA.

Is this a statement about current implementations or is it a
requirement? If the latter, then in which RFC is that requirement
stated? AFAICS RFC5666 uses the term "service address", but nowhere is
it stated that has to be an IP address; only that it must have a
corresponding mapping into a universal address.

>  - To handle large payloads (possibly required by certain pNFS
>    CB operations), an NFSv4.1 client would need to handle
>    RDMA_NOMSG type calls over the backchannel. This would require
>    the client to perform RDMA READ and WRITE operations against the
>    server (the opposite of what happens in the forward channel).

Only if it wants to. The maximum size of backchannel payloads is
negotiated at session creation time. Both the server and the client
have to opportunity to negotiate that limit down to something
reasonable.

I'm assuming that you are referring to CB_NOTIFY_DEVICEID because it
takes an array argument? There is nothing stopping the server from
breaking that down into multiple calls if the payload is too large.
Ditto for CB_NOTIFY, btw.

> There is some interest in prototyping an RPC/RDMA transport that is
> capable of bi-directional RPC. A prototype would help us determine
> whether there are subtle problems that make bi-RPC impossible for
> RPC/RDMA, and identify any spec gaps that need to be addressed.
> Because of the development cost and lack of perceptible benefits, a
> prototype has not been attempted so far.
>
> Would it be productive for a bi-capable RPC/RDMA transport prototype
> to be pursued in Linux?

Yes.

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

Offhand I can think of at least 2 issues:

- How does the client determine which IP address to use for the TCP channel?
- How does the client and server detect that the TCP connection is
still up when there is no activity on it?

Trond
