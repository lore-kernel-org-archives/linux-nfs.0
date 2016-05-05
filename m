Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46646 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755821AbcEEVCF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 17:02:05 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Configuring NFSv4.0 Kerberos on a multi-homed Linux NFS server
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <DB5B2D02-412E-46AD-9F0A-7EBA4EB0C0B0@oracle.com>
Date: Thu, 5 May 2016 17:01:58 -0400
Cc: Bruce Fields <bfields@fieldses.org>
Message-Id: <8198666A-8963-42D2-9C4C-08374F0E8E5D@oracle.com>
References: <DB5B2D02-412E-46AD-9F0A-7EBA4EB0C0B0@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 5, 2016, at 12:04 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> Hi-
> 
> I have a Linux NFS server with two IP addresses:
> 
> 192.168.1.55: klimt.home
> 10.0.0.5: klimt-ib.home
> 
> The server's keytab lists three principals:
> 
> host/klimt.home@HOME.EXAMPLE.NET
> nfs/klimt.home@HOME.EXAMPLE.NET
> nfs/klimt-ib.home@HOME.EXAMPLE.NET
> 
> When I mount with this:
> 
>  vers=4.0,proto=tcp,sec=sys klimt:/export
> 
> I get krb5i for lease management, and sys for data traffic.
> Callback traffic from the server uses krb5i. All well and
> good.
> 
> When I mount with this:
> 
>  vers=4.0,proto=tcp,sec=sys klimt-ib:/export
> 
> I get krb5i for lease management and sys for data traffic
> as before, and callback traffic attempts to use krb5i.
> But the client rejects all CB_COMPOUND operations because
> the callback principal does not match the clp.
> 
> Looks like the server always uses the nfs/klimt service
> principal for callback traffic? Is there a way to config
> the server to use the principal that matches the
> interface? Or is there something else going on?

After some IRC discussion with Bruce, we think the answer
is "this is not supported in the current Linux NFS server."

The server does not have a way to determine which service
principal to use for NFSv4.0 callback operations. It picks
(probably) the first nfs/ service principal in the server's
keytab for all callback operations.

Thus if a Linux NFS server has a keytab, clients can mount
it with NFSv4.0 (and any security flavor) only on the i/f
whose hostname matches the name of the nfs/ service
principal in that server's keytab.

In other words, if the server has a keytab with the
principals:

  nfs/server-a
  nfs/server-b
  nfs/server-c

NFSv4.0 will operate correctly only when mounting the
server via server-a: .

Clients that do not have a keytab should be able to mount
with NFSv4.0 via the other interfaces. This is because
they will not try to negotiate krb5i for lease management,
and the server will not attempt to use krb5i for callback
operations.

Bruce feels this is a corner case, would be difficult to
address, and is adequately worked around by using NFSv3
or NFSv4.1 or higher. So currently this is a WONTFIX.

Copied Bruce to correct anything I might have summarized
incorrectly.

--
Chuck Lever



