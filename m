Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:49062 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab1JaNIH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 09:08:07 -0400
Subject: Re: NFS4ERR_STALE_CLIENTID loop
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111029195249.GE2011@rd.bbc.co.uk>
Date: Mon, 31 Oct 2011 09:07:48 -0400
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Message-Id: <6FEDF9D0-B059-4580-931C-7EBBD1F8C8EA@oracle.com>
References: <20111024145027.GF32587@rd.bbc.co.uk> <1319470302.2734.4.camel@lade.trondhjem.org> <20111027221742.GI32587@rd.bbc.co.uk> <20111029002500.GA2011@rd.bbc.co.uk> <1319909376.2760.11.camel@lade.trondhjem.org> <20111029181509.GE12122@fieldses.org> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7474@SACMVEXC2-PRD.hq.netapp.com> <20111029184759.GG12122@fieldses.org> <4B27362C-FBC1-4F64-B611-85D5FF6C5359@oracle.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7479@SACMVEXC2-PRD.hq.netapp.com> <20111029195249.GE2011@rd.bbc.co.uk>
To: David Flynn <davidf@rd.bbc.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2011, at 3:52 PM, David Flynn wrote:

> * Myklebust, Trond (Trond.Myklebust@netapp.com) wrote:
>>> -----Original Message-----
>>> From: Chuck Lever [mailto:chuck.lever@oracle.com]
>>> On Oct 29, 2011, at 2:47 PM, J. Bruce Fields wrote:
>>>> Yes, and it's not something I care that strongly about, really, my
>>>> only observation is that this sort of failure (an implementation
>>>> bug on one side or another resulting in a loop) seems to have been
>>>> common (based on no hard data, just my vague memories of list
>>>> threads), and the results fairly obnoxious (possibly even for
>>>> unrelated hosts on the network).
>>>> So if there's some simple way to fail more gracefully it might be
>>>> helpful.
>>> 
>>> For what it's worth, I agree that client implementations should
>>> attempt to behave more gracefully in the face of server problems, be
>>> they the result of bugs or the result of other issues specific to
>>> that server.  Problems like this make NFSv4 as a protocol look bad.
>> 
>> I can't see what a client can do in this situation except possibly just
>> give up after a while and throw a SERVER_BROKEN error (which means data
>> loss). That still won't make NFSv4 look good...
> 
> Indeed, it is a quite the dilemma.
> 
> I agree that giving and guaranteeing unattended data loss is bad (data
> loss at the behest of an operator is ok, afterall they can always fence
> a broken machine).

David, what would help immensely is if you can find a reliable way of reproducing this.  So far we have been unable to find a reproducer.

> Looking at some of the logs again, even going back to the very original
> case, it appears to be about 600us between retries (RTT=400us).  Is
> there any way to make that less aggressive?, eg 1s? -- that'd reduce the
> impact by three orders of magnitude.  What would be the down-side?  How
> often do you expect to get a BAD_STATEID error?
> 
> ..david

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




