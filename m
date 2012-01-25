Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:22293 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756429Ab2AYRli convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 12:41:38 -0500
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120125171401.GI17873@fieldses.org>
Date: Wed, 25 Jan 2012 12:41:27 -0500
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <D13C2C6D-7731-4EE6-BC3D-2A9D1D1F0581@oracle.com>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com> <20120124230855.GE12426@fieldses.org> <20120125064158.4551a012@tlielax.poochiereds.net> <20120125131116.GA17873@fieldses.org> <20120125083820.637c8362@tlielax.poochiereds.net> <F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com> <20120125171401.GI17873@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On Jan 25, 2012, at 12:14 PM, J. Bruce Fields wrote:

> On Wed, Jan 25, 2012 at 11:47:41AM -0500, Chuck Lever wrote:
>> I'm having a hard time following the discussion, I must be lacking some context.  But the problem is how NFSv4.0 clients detect server identity.  The only way they can do it is by performing a SETCLIENTID_CONFIRM with a particular clientid4 against every server a client knows about.  If the clientid4 is recognized by multiple server IPs, the client knows these IPs are the same server.
>> 
>> Thus if you are preserving clientid4's on stable storage, it seems to me that you need to preserve the relationship between a clientid4 and which servers recognize it.
> 
> The part I'm having trouble thinking about:
> 
> Suppose your cluster nodes all advertise each other as replicas using
> v4 (fs_locations or fs_locations_info).
> 
> Suppose your clients support (v4-based) failover, either transparent or
> not.
> 
> Now suppose your cluster reboots.
> 
> Must the client necessarily reclaim its locks against the same server
> that it last acquired them from?  And if not, how do we decide whether a
> given reclaim is allowed or not?

This is just my opinion, but...

One might define an NFSv4 server as an entity that passes out and recognizes clientid4's.

Suppose a client is talking to NFSv4 servers at IP addresses A and B.  If the client gets a clientid4 from IP address A and performs a failing SETCLIENTID_CONFIRM with that clientid4 on IP address B, then one can say that A and B are IP addresses for distinct servers.

If the SETCLIENTID_CONFIRM succeeds, however, then the client must try other tests to confirm that A and B represent the same server.  For example, can the client use the same state tokens when sending NFsv4 operations to A and B?

> I think there may be scenarios involving server reboots and the client
> losing contact with some but not all servers, where we could get
> confused about which (if any) state the client is allowed to reclaim.

If SETCLIENTID returns a unique clientid4 that a client hasn't seen from other servers, the client knows that's a unique server instance which must be recovered separately after a reboot.

Conversely, if all the servers in your cluster recognize a particular clientid4, then there must be some kind of state sharing relationship amongst them.  Reclaiming against one should be sufficient.  Not all clustering works that way, though.

fs_locations can pass out information for entirely separate server instances.  fs_locations does not in any way indicate a relationship of state or data consistency between the servers in the lists it returns.  fs_locations_info, in fact, returns much richer information that allows clients some visibility of state and data consistency amongst the listed servers.  But the mere presence of a server in one of these lists is not enough for a wayward client to draw any conclusions about the need to reclaim state after a server reboot.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




