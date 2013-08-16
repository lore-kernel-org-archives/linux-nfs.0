Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40908 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752707Ab3HQALz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Aug 2013 20:11:55 -0400
Date: Fri, 16 Aug 2013 16:51:33 -0400
To: Orion Poplawski <orion@cora.nwra.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: rpc.idmapd: nss_getpwnam: name '#' does not map into domain
Message-ID: <20130816205133.GA21539@fieldses.org>
References: <loom.20130814T210744-290@post.gmane.org>
 <loom.20130814T212246-502@post.gmane.org>
 <1376510917.29258.55.camel@leira.trondhjem.org>
 <520BE844.9030408@cora.nwra.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <520BE844.9030408@cora.nwra.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 14, 2013 at 02:27:48PM -0600, Orion Poplawski wrote:
> On 08/14/2013 02:08 PM, Myklebust, Trond wrote:
> >On Wed, 2013-08-14 at 19:24 +0000, Orion Poplawski wrote:
> >>Orion Poplawski <orion@...> writes:
> >>
> >>>
> >>>On our EL6 nfs servers we see periodic messages like:
> >>>
> >>>Aug 14 12:55:19 alexandria rpc.idmapd[19237]: nss_getpwnam: name '612' does
> >>>not map into domain 'cora.nwra.com'
> >>>
> >>>I imagine that this is caused by a client actually passing the uid instead
> >>>of the username for some reason but I have no idea how to track down which.
> >>>  Any ideas?
> >
> >Are you seeing any _actual_ application errors?
> 
> Not that I'm aware of.
> 
> >>These *appear* to be triggered by the following types of requests:
> >>
> >>
> >>Network File System, Ops(3): PUTFH SETATTR GETATTR
> >
> >That is 100% expected behaviour if you are using AUTH_SYS on the client
> >(see the explanation in RFC3530bis). The default there is to use
> >unmapped uids and gids for backward compatibility with NFSv3, and to
> >ensure that the names/groups used by NFSv4 match the uids/gids used by
> >the AUTH_SYS authentication.
> >
> >In the case where the NFSv4 server doesn't support that mode of
> >operation, it is expected to return NFS4ERR_BADOWNER (although Linux
> >clients also accept NFS4ERR_BADNAME) in which case the client will
> >switch to using mapped ids.
> 
> Thanks, finally came across that.  I'm wondering if it is worth
> changing libnfsidmap to not log this message in these cases.

Could be.  Newer idmapd may have some other changes here too, I don't
remember.

Note newer upstream server kernels will accept numeric id's from the
client.

--b.
