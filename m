Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60752 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725950AbeHOV3p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Aug 2018 17:29:45 -0400
Date: Wed, 15 Aug 2018 14:36:28 -0400
To: mrsvd1v4rgo1@airpost.net
Cc: linux-nfs@vger.kernel.org
Subject: Re: Help with user ID mapping?
Message-ID: <20180815183628.GA29569@fieldses.org>
References: <1533838052.2201783.1469033928.4B670F71@webmail.messagingengine.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1533838052.2201783.1469033928.4B670F71@webmail.messagingengine.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 09, 2018 at 11:07:32AM -0700, mrsvd1v4rgo1@airpost.net wrote:
> I'm trying to get a NFS4 client & server id mapping working right.
> 
> My client mounts to a couple of NFS4 servers.
> 
> I want to get it setup so that for just ONE of them, files added to or
> modified on the server BY my local client, logged in EITHER as my user
> or root, get written with a specific user/group ==  "nobody:users"

You should be able to do that by just adding "all_squash" to the export
options in /etc/exports for that one client.

> I'm pretty sure that all the magic is done with idmapd config.

This is a common source of confusion.  NFSv4 idmapping only deals with
names and IDs that are sent in NFSv4 protocol messages--when setting or
getting file owners and groups, or ACLs.

It's the underlying RPC protocol that tells the server who is performing
a given RPC.  That always uses numeric IDs or krb5 principals, and isn't
affected by anything in idmapd.conf.

--b.
