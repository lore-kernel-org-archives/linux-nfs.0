Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:44580 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686Ab2JBOYc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Oct 2012 10:24:32 -0400
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only server?
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121002152440.2e6a0c04@notabene.brown>
Date: Tue, 2 Oct 2012 07:24:23 -0700
Cc: NFS <linux-nfs@vger.kernel.org>
Message-Id: <7459FD75-3B8A-4973-A732-1984A658C65D@oracle.com>
References: <20120918115450.5c65973f@notabene.brown> <F8762BC2-F211-482E-8B5A-A2E991E3F937@oracle.com> <20120918162948.47840d42@notabene.brown> <ECDC5BA9-29CC-4867-8737-CA1110E6C4C6@oracle.com> <20120919091904.624ee54b@notabene.brown> <ECD54A5F-C684-4057-96F5-1D29E7A9A551@oracle.com> <20121002152440.2e6a0c04@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 1, 2012, at 10:24 PM, NeilBrown wrote:

> On Tue, 18 Sep 2012 21:00:01 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
>>> +A
>>> +.I netid
>>> +determines both the
>>> +.I transport
>>> +and
>>> +.I network
>>> +protocols, so for example
>> 
>> "determines both the protocol family and transport" are closer to how these terms are defined in netconfig(5), and I prefer that formulation.  I still believe a citation of netconfig(5) would be correct and helpful.  A citation in the SEE ALSO section should also be added.
> 
> (SEE ALSO already mentions netconfig(5).)
> 
> Don't you love standards....
> 
> ISO OSI seems to use "network" for layer 3 and "transport" for layer 4, which
> is where I got that names I used.
> 
> netconfig(5) uses "protocol family" and "protocol" respectively, and
> "transport" to identify the combination of the two (which is also the
> network_id).
> 
> socket(2) also uses "protocol family" and "protocol", but uses AF as the
> prefix for "protocol family" aka "address family" :-)
> 
> This does serve to highlight the inappropriateness of using "proto=" to
> specify the "transport", and the netconfig usage treats the "protocol" as a
> just part of the "transport" (but allows e.g. "udp" to be both a protocol and
> a transport depending on context).
> 
> It looks like  "protocol" and "protocol family" are the most appropriate
> terms in the Unix world, and the examples can clear up any uncertainty:
> 
> ------------
> A
> .I netid
> determines both the
> .I protocol
> and
> .IR "protocol family" .
> So for example
> .B udp
> selects UDP over IPv4 while
> .B tcp6
> selects TCP over IPv6.
> -----------------
>> 
>> As a matter of word smithing, I think starting a new sentence at "so for example" would be easier to read.
> 
> Agreed.
> 
> So how about this.
> 
> Thanks,
> NeilBrown
> 
> 
> From: Neil Brown <neilb@suse.de>
> Date: Tue, 2 Oct 2012 15:21:46 +1000
> Subject: [PATCH] mount.nfs mapage: clear up confusion between 'proto' and
> 'transport'
> 
> The mount option "proto=" actually set the "transport" which in
> netconfig usage is the paring of a protocol (e.g. UDP, TCP) with
> a protocol family (e.g. INET, INET6).
> 
> This can cause confusion if people naively except "proto=udp" to work
> equally well on IPv6.
> 
> So add some text to both nfs(5) and nfsmount.conf(5) to hopefully
> clarify this.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index da6d6d3..2741a60 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -1,5 +1,5 @@
> .\"@(#)nfs.5"
> -.TH NFS 5 "2 November 2007"
> +.TH NFS 5 "19 September 2012"
> .SH NAME
> nfs \- fstab format and options for the
> .B nfs
> @@ -474,9 +474,17 @@ for NFS versions 2 and 3 only.
> .BI proto= netid
> The transport protocol name and protocol family the NFS client uses
> to transmit requests to the NFS server for this mount point.
> -If an NFS server has both an IPv4 and an IPv6 address, using a specific
> -netid will force the use of IPv4 or IPv6 networking to communicate
> -with that server.
> +A
> +.I netid
> +determines both the
> +.I protocol
> +and
> +.IR "protocol family" .

Looking at this addition in context, the new sentence simply repeats the existing first sentence in the paragraph.  How about we clarify the existing first sentence, and just add your example:

> proto=netid
> 
> The protocol and protocol family the NFS client uses to transmit requests to the NFS server for this mount point.  For example, udp selects UDP over IPv4, while tcp6 selects TCP over IPv6.  If an NFS server has both an IPv4 and an IPv6 address, using a specific netid forces the use of IPv4 or IPv6 networking to communicate with that server.

We have a slightly sticky problem, then.  TI-RPC brings more to the table than udp/udp6 and tcp/tcp6.  For instance, we also now have rdma/rdma6 netids (not mentioned anywhere, ha) and there is a local transport netid.  If there ever is support for RPC over SCTP, that would also get its own pair of netids.  The problem is that not all of these netids are supported by NFS right now.  I think nfs(5) might benefit by providing a list of supported netid values.

This could make the above paragraph perhaps too long.  We should consider adding a section to nfs(5) that discusses this in a little more detail.  That can be a separate patch, of course.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



