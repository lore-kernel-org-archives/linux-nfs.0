Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36040 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751966AbdJEUIl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Oct 2017 16:08:41 -0400
Date: Thu, 5 Oct 2017 16:08:35 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Matt Benjamin <mbenjami@redhat.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Daniel Berrange <berrange@redhat.com>
Subject: Draft RFC for ONC RPC over AF_VSOCK
Message-ID: <20171005200835.GA31525@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have previously submitted patches that implement NFS client and nfsd
support for the AF_VSOCK address family.  In order for this to be
acceptable for merge the AF_VSOCK transport needs to be defined in an
IETF RFC.  Below is a draft RFC that defines ONC RPC over AF_VSOCK.

My patches use netid "vsock" but "tcpv" has also been suggested.  This draft
RFC still uses "vsock" but I'll update it to "tcpv" if there is consensus.

The uaddr format proposed in this RFC is not implemented yet.  RPCBIND and the
NFSv4 callback were not supported in my previous patch submissions but it's
clear that a uaddr format is required for full ONC RPC support so I've
included it.

Discussion and pointers for getting this in shape for submission with
the IETF would be appreciated!  I will apply final RFC formatting before
submission and am mostly concerned about content at this stage.

Thanks,
Stefan
---

Remote Procedure Call (RPC) Network Identifier and Universal Address Format
Definitions for the AF_VSOCK Transport

S. Hajnoczi
Red Hat, Inc.
October 2017

1. Introduction and Motivation

The AF_VSOCK address family facilitates socket communication between a
hypervisor and virtual machines running on the hypervisor.  It was implemented
in Linux 3.9 with initial transport support for VMware.  Further transports
were added for KVM and Hyper-V hypervisors later.  AF_VSOCK services can
run on any supported hypervisor because the network address and semantics
remain the same across AF_VSOCK transports.

ONC RPC services are bound to transport addresses (RFC 1833 [1]).  Transport
addresses are described by netid and universal address strings.  This standard
representation of transport addresses allows address information to be
communicated between client programs and RPC services, including the RPCBIND
program.

It is necessary to define a network identifier and universal address
representation so that ONC RPC may be used over AF_VSOCK.  This document
describes string representations for the AF_VSOCK netid and universal
addresses.

2. Requirements Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in RFC 2119 [2].

3. Security Considerations

AF_VSOCK addresses are local to the hypervisor instance that the virtual
machine is running on.  Source address spoofing is not possible because the
hypervisor enforces the assigned address of the virtual machine.  RPC services
running on the hypervisor MAY use the source address for authorization if they
do not implement additional security features.

4. Intended Use

The intended use of this new ONC RPC transport is Network File System (NFS)
v4.1 (RFC5661 [3]) to export file systems from the hypervisor into virtual
machines.  Other RPC services could also be used with the hypervisor offering
the service to the virtual machine or vice versa.

The need for an AF_VSOCK transport arises because management tools require the
ability to deploy RPC services for virtual machines in an automated fashion.
Existing TCP/IP network interface configuration, including firewall
configuration, is difficult to automate without risk of interfering with the
virtual machine owner's networking configuration.  AF_VSOCK provides a
zero-configuration communications channel with the dedicated purpose of
communicating between a hypervisor and virtual machines without these
configuration difficulties.

5. Network addresses

AF_VSOCK addresses contain an unsigned 32-bit integer called the Context
Identifier (CID) that is the network address.  An unsigned 32-bit integer port
number acts as the transport selector so that multiple services can be offered
on a single network address.

CID values in the range [0, 2] are reserved.  Virtual machines are assigned
values outside this range.  The hypervisor exposes services on the well-known
CID value 2.

Ports in the range [0, 1023] are privileged and can only be bound by programs
that have sufficient privilege.

6. Netid for AF_VSOCK

The netid for AF_VSOCK is given in Table 1.

   +---------+----------+-------------------------------+------+------+
   | Netid   | Constant | RFC(s) and Description (if    | PoC  | CR   |
   |         | Name     | needed)                       |      |      |
   +---------+----------+-------------------------------+------+------+
   | "vsock" | NC_VSOCK | Netid for AF_VSOCK.           | IESG | TBD1 |
   |         |          | Section 6 of RFC TBD1.        |      |      |
   +---------+----------+----------------------------- -+------+------+

PoC: Point of Contact.

CR: Cross Reference to the Uaddr Format Registry.

Table 1: Netid for AF_VSOCK

7. Uaddr Format for AF_VSOCK

The format of the uaddr for AF_VSOCK is the US-ASCII string:

   cid.port

The "cid" prefix is the ASCII-decimal representation of the CID network
address.  The "port" suffix is the ASCII-decimal representation of the
port number transport selector.

   +-------+------------------------------------+------+-------+
   | Basis | Description and/or Reference       | PoC  | CR    |
   +-------+------------------------------------+------+-------+
   | STDS  | Uaddr format for AF_VSOCK.         | IESG | TBD1  |
   |       | Section 7 of RFC TBD1.             |      |       |
   +-------+------------------------------------+------+-------+

Table 2: Uaddr format for AF_VSOCK

8. Record Marking

AF_VSOCK sockets of type SOCK_STREAM are used for connection-oriented,
in-order, guaranteed delivery semantics.  These bytestream semantics require
that RPC messages are delimited so message boundaries can be detected.

The Record Marking Standard, defined in RFC 1831 Section 10 [4], is used for
this purpose.

9. References

   [1]   Srinivasan, R., "Binding Protocols for ONC RPC Version 2",
         RFC 1833, August 1995.

   [2]   Bradner, S., "Key words for use in RFCs to Indicate Requirement
         Levels", BCP 14, RFC 2119, March 1997.

   [3]   Eisler, M., "IANA Considerations for Remote Procedure Call (RPC)
	 Network Identifiers and Universal Address Formats", RFC 5665,
         January 2010.

   [4]   Srinivasan, R., "RPC: Remote Procedure Call Protocol Specification
         Version 2", RFC 1831, August 1995.
