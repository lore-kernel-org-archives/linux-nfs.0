Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:32147 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190Ab1HBOxp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Aug 2011 10:53:45 -0400
Subject: Re: State of NFSv4 VolatileFilehandles
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E37E66D.90102@linux.vnet.ibm.com>
Date: Tue, 2 Aug 2011 10:53:33 -0400
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com
Message-Id: <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
References: <4E37E66D.90102@linux.vnet.ibm.com>
To: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 2, 2011, at 7:58 AM, Venkateswararao Jujjuri wrote:

> We at IBM receiving multiple customer requests for supporting NFSv4 server migration.
> I have referred to Trond and Chuck's presentations at 2011 Connectathon and there appears to be
> sizable work remaining. I am not sure if there is any progress made since those talks.
> 
> I would like to open up a discussion thread on the mailing list to understand the latest status.
> Also would like to get the input on the Volatile Filehandles (VFH). I searched the mailing list, and could not
> find any recent discussion on this.
> 
> Some discussion points:
> - What are the pieces left to attain full client/server support for seamless server migration?

The client migration implementation is code complete and in test now.  This includes both minor version 0 and 1.  We don't have any mv1 servers to test with at this time, so that support is provisional.  I hope to have patches ready for the 3.2 merge window, but you can see what I've got now on git.linux-nfs.org.

A problem is that there are corner cases in the v4.0 migration specification that are still unresolved.  We are working with the NFSv4 WG to get these addressed.  But I expect some minor changes even after the patches are merged upstream.

We don't have firm plans for a server migration implementation on Linux at this time, but Bruce can maybe say more about that.

> - Any discussion/sugestions on the way to implement VFH?  As described in RFC 3530 sections 4.2.3 and 4.2.4?

I think we are avoiding volatile file handles as long as possible.  We don't have plans to implement them at the moment.

> - Are there any community efforts going / about to start in this area? so that we can partner and get
>  things done instead of duplicating the work.
> 
> Thanks a lot for your help
> JV

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




