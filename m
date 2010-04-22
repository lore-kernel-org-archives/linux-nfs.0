Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp151.dfw.emailsrvr.com ([67.192.241.151]:49635 "EHLO
	smtp151.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742Ab0DVS2j convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Apr 2010 14:28:39 -0400
From: "Brandon Shandelson" <brandon@myshape.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
References: <01c701cae247$e8e50900$baaf1b00$@com> <20100422182213.GA8858@fieldses.org>
In-Reply-To: <20100422182213.GA8858@fieldses.org>
Subject: RE: NFSV4 Replica Support?
Date: Thu, 22 Apr 2010 11:30:00 -0700
Message-ID: <01c801cae249$d17ab3d0$74701b70$@com>
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I have two NFS servers with NFSV4 exports whose data are synced via Unison.  I want one server to be a hot standby for clients to use in case something happens to the primary NFS server.

The NFS exports look like this:
/home 192.168.0.0/24(rw,fsid=0,insecure,no_subtree_check,async,repli cas=/home@msdevnfs1:/home@msdevnfs2)

The mount in fstab looks like this:
msdevnfs1:/ /home nfs4 _netdev,auto 0 0


-Brandon

-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
Sent: Thursday, April 22, 2010 11:22 AM
To: Brandon Shandelson
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSV4 Replica Support?

On Thu, Apr 22, 2010 at 11:16:20AM -0700, Brandon Shandelson wrote:
> I want to use NFSV4 replicas on Ubuntu 9.10 64-bit servers.  It doesn’t seem
> to work.  It *looks* like the server kernel module supports it, but the NFS
> client does not.  Is this the case, or should I be able to make replicas
> work on Linux?

What are you actually trying to do?

There's a little support for replication in that the NFSv4 server can be
told to report certain locations as having the same data, but it's not
really supported yet: you need smoething to create the replicas for you
(probably doable with GFS2 as the exported filesystem, or by sharing the
filesystem image if it's read-only).  I don't think the Linux NFSv4
client knows how to use that information yet.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

