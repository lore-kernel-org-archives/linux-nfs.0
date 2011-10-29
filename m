Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:17601 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933857Ab1J2SvR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 14:51:17 -0400
Subject: Re: NFS4ERR_STALE_CLIENTID loop
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111029184759.GG12122@fieldses.org>
Date: Sat, 29 Oct 2011 14:50:58 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org
Message-Id: <4B27362C-FBC1-4F64-B611-85D5FF6C5359@oracle.com>
References: <1319455367.8505.3.camel@lade.trondhjem.org> <20111024131734.GE32587@rd.bbc.co.uk> <1319463165.2734.1.camel@lade.trondhjem.org> <20111024145027.GF32587@rd.bbc.co.uk> <1319470302.2734.4.camel@lade.trondhjem.org> <20111027221742.GI32587@rd.bbc.co.uk> <20111029002500.GA2011@rd.bbc.co.uk> <1319909376.2760.11.camel@lade.trondhjem.org> <20111029181509.GE12122@fieldses.org> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7474@SACMVEXC2-PRD.hq.netapp.com> <20111029184759.GG12122@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2011, at 2:47 PM, J. Bruce Fields wrote:

> On Sat, Oct 29, 2011 at 11:21:13AM -0700, Myklebust, Trond wrote:
>>> From: J. Bruce Fields [mailto:bfields@fieldses.org]
>>> On Sat, Oct 29, 2011 at 07:29:36PM +0200, Trond Myklebust wrote:
>>>> OK. This is the first time I've seen this tcpdump.
>>>> 
>>>> The problem seems like a split-brain issue on the server... On the
>> one
>>>> hand, it is happily telling us that our lease is OK when we RENEW.
>>>> Then when we try to use said lease in an OPEN, it is replying with
>>>> STALE_CLIENTID.
>>>> 
>>>> IOW: This isn't a problem I can fix on the client whether or not I
>> add
>>>> exponential backoff. The problem needs to be addressed on the server
>>>> by the Solaris folks....
>>> 
>>> Is there any simple thing we could do on the client to reduce the
>> impact of
>>> these sorts of loops?
>> 
>> WHY? Those loops aren't supposed to happen if the server works according
>> to spec.
> 
> Yes, and it's not something I care that strongly about, really, my only
> observation is that this sort of failure (an implementation bug on one
> side or another resulting in a loop) seems to have been common (based on
> no hard data, just my vague memories of list threads), and the results
> fairly obnoxious (possibly even for unrelated hosts on the network).
> So if there's some simple way to fail more gracefully it might be
> helpful.

For what it's worth, I agree that client implementations should attempt to behave more gracefully in the face of server problems, be they the result of bugs or the result of other issues specific to that server.  Problems like this make NFSv4 as a protocol look bad.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




