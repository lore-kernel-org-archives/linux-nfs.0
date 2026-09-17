Received: from fhigh-b2-smtp.messagingengine.com (fhigh-b2-smtp.messagingengine.com [202.12.124.153])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B8C538F65C
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 21:46:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.153
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789681577; cv=none; b=b7ftXAevo/F6cltj0sN9b+pUmbzW+4D5nZo7Q4eUVOJlBBdUgL/SG0pVzXFL6Cn7IIsJmKj467gU6Eu7Mk1o4XfsiB+F3Pp0/SibzchBonnKnbFJFBjuy+b3gP3jMHc23cl9Dp5FakXhR9N1zZd8x6csBOsTMB2il+DtndYil0c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789681577; c=relaxed/simple;
	bh=ZNlgHe7rClBJ6TNFHIr44FBXelpYsaDy0deuc3Ame0I=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=TqiGM31pDyYx+RILi3FZtkufgHt+Bapt+JH2nJRNx1MS9RtzYZO3U0GeEyNCK0OFuW8L6bmoq9E6MhAJ6UnmI0iIUtk4hjrjS3nei4ywaoWo337grte6UvzVlzsjSgTx9n41K1scH3FiZvvX293EKQCDXf5Wul5KKcbtHvG5hGE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=apdWoKv5; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=LQukZofW; arc=none smtp.client-ip=202.12.124.153
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="apdWoKv5";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="LQukZofW"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 049327A01C4;
	Thu, 17 Sep 2026 17:46:13 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Thu, 17 Sep 2026 17:46:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789681573; x=1789767973; bh=aFcs1MTRt5FfzyNe3wQe45a2saa/yhxatq/
	+QvgPtsk=; b=apdWoKv56ggzstS4u3iTjKPespJUpPEaB8X1p+pIkLjl0x3+DdC
	KYUy7JPvo4a8fH4ScORsudMCllOQvhrMPnUtjiyXV3/+ieS5DriUvw1e9zesa65T
	z0ZSU2WcAiPCSYgArmEycScO/8BshRGDMeQmhhFpja0+MvHhUigTcdlUVftZtvDS
	SvrzCdCTdgyKZpfDI6lZI5pVtkLQfPJ33E8Qos5fkS1eOFU5bPt+W3/aXpp9thaa
	SHekNAiU4l8JoLhVQUunEpD8m0vwtWq5nKDSJRrUk6m63HR6IvOZju7MliT2/08o
	IJprbKjWsO/O4shSjIDs+aQBzsX+ishrqKg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789681573; x=
	1789767973; bh=aFcs1MTRt5FfzyNe3wQe45a2saa/yhxatq/+QvgPtsk=; b=L
	QukZofW2xx3Tu4/0uuEyQXEjMGXdO46mMT4OUS704s38ubKVAeu1oJqLjhuFQX6Y
	jeHS1m8sQs+3HZ3c9D17B79Z/UHjNkZx4M7CPgl+sDoOJawcjUm4oTfKur8haoWc
	WiTashjSUFaVhraLd7ZHQ7KH9KFxwFsWG2+qiGiJ5+EtaHyAlwhI2X5Aq9HbCy6+
	QspetSdgP/tAww/yh6FMgFcwSwGL/jrQb/I3JJpTXsH/X8qb1qmpplFZcCrEgthk
	1SM1qkdosdVc0Xzk9QuRVUzT+fx2CaF0O3bDTC+IdWUO8SVFv/DxcmMUgTkE6UiY
	ND7DQd5dgFMDq9akzkx/w==
X-ME-Sender: <xms:pV-sagzaRkbfzBYvc1CTHHbgZDaCVrShx-LqL1BmQ9fDSvjbp5IAlQ>
    <xme:pV-samij7_3-zGIZU5E7lhlWJ15926z57N44UmkSc2Il9xIh19aY2CpuQk9rvdwXN
    l7RjBwARhWu4b1Repi8doVibvwM68c9uTgPQebzNICtRtuoybyu>
X-ME-Received: <xmr:pV-saknf-yooQnAAnKkxq8-bqtxr17DYda9mnmpnEQONMOBJhirPyA7zeQuUOgW-KsTG9JkDMXSr9qpLuUNNpL1NiYAnsFU>
X-ME-Proxy-Cause: dmFkZTEsLPNT7BWXIFqp8ln4h19aiSZnI7I3PEiCBsQ7PR7jKjqFtw0l3O54dWfXilAKzE
    /7X+kldF3yutEruEYhYAE/QxU3mSptm/vau01OAvWvNZ6HC1eYfwJW2z04fSAN9/UabCdQ
    b0RRP87ez8e1+R16WcgFRsy0rVUCq5zhV7yx32jsffaORBhYtS/m7K2Ifi4Y5s+uqGODIQ
    B1JUjBVStraFgevcSVgHaXJMCLyuO04xiWGEeF0C4wMIxTqGsnCxM1kpYutN2n5iMcnjUq
    K0y4LKCzaG2IRFf14HvHZhsL1CcxOEivs+EcxQB+AOTG+a8FUIjZo0a+B5dE8p6oAc5KXl
    Zk4gButR+LB1bQJW2lswoux/g+dYBv7uU53aOeRqdMLkoI8Bh/CSiuc3RcCsaJNf0RCvxF
    ojPosOwiWxO4S/Mq+hCMuu4NTTJuT0yJ+u6wzK+wOfzKcwtF0LRpgNx2F6Gx4clb9gavn/
    Lw3aip3hqcIjAN8gdJn2gWSOTeoT4V3aV0Sf1JMSya4kPrHR9e5IxtuhQKskgQzW6zVC/z
    UTMFQYJWLLDBFWH/Ak/9/TEseF4n3vvUmOHQl5eGoOzgoLKkVVk3DFaowOTLqx+Jwwc9Q+
    NdtxzN5gbb16MJe4qh2P/yIwnjFEFhC24ya3kc6M4DB5hc9u2Epud6iibfDw
X-ME-Proxy: <xmx:pV-sakgW1UsrSBZpLJb6jrlqtxsY4V0QMtBiVypeS6mG4utm_xb__Q>
    <xmx:pV-sag0B1P1f8khjiY6RDGaET1wEJqHV7R4TEnNX6uRPMREeKKxEHw>
    <xmx:pV-salKAfxzyNd17moh5Rr52dPa8XvPrN6REWt7v1WyAGnpFr63nJQ>
    <xmx:pV-saoyqBYv7LeG7fCpa8Cjm51_VI_WfhNJWDaxU1cPml2BWyiIzEw>
    <xmx:pV-sagO5IVCzt_npktG1PpNOTOCGR7qDJucdsFg87gbw82YnnywHp0bi>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 17 Sep 2026 17:46:11 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 00/11] Improve the scalability of NFSD's classic DRC
In-reply-to: <4aa8dccd-256f-4f6a-8be3-dc832ffdaccf@app.fastmail.com>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
  <178945353329.207413.1555757673936041397@noble.neil.brown.name>
  <038f948f-64d7-434d-ae51-2e692c3b71b9@slotpi15m67>
  <178959882426.207413.6596745257975294056@noble.neil.brown.name>
  <4aa8dccd-256f-4f6a-8be3-dc832ffdaccf@app.fastmail.com>
Date: Fri, 18 Sep 2026 07:46:07 +1000
Message-id: <178968156727.207413.14622543870891027608@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 18 Sep 2026, Chuck Lever wrote:
> 
> On Wed, Sep 16, 2026, at 6:47 PM, NeilBrown wrote:
> > On Wed, 16 Sep 2026, Chuck Lever wrote:
> >> On Tue, 15 Sep 2026, NeilBrown wrote:
> >> > In any case, There is zero chance an NFS server will get a
> >> > retransmission of an NFS request over TCP within 120 seconds unless the
> >> > admin has significantly reduced the timeo / retrans options.
> >> > So maybe there is no point caching these at all???
> >> 
> >> Agreed that 120 seconds serves nobody on TCP. But the retransmit that
> >> matters arrives on a new connection, after a partition or a client
> >> timeout, and by then the old connection's send buffer is gone. The
> >> DRC is the only mechanism that can handle it.
> >> 
> >> 
> >> > Or maybe once we get this more efficient pruning working, we can extend
> >> > the lifetime for cached TCP replies to something potentially useful,
> >> > like 15 minutes.  Or more.
> >> 
> >> That's the direction I would prefer to take. We spent a lot of effort
> >> on the courteous server so NFSv4 state survives partitions that might
> >> last hours. The DRC should cover the same window for NFSv3, if that is
> >> at all feasible.
> >
> > Thanks - this is useful context and feeds into the design I think.
> > Particularly the LRU and pruning.
> >
> > I imagine having 3 separate LRUs for cache entries.
> > 1/ the current per-bucket LRU - entries on this are prune after
> >    a timeout and when the size gets too big, exactly as present.
> > 2/ a new per-xprt LRU which tracks all the request on that xprt
> >    which are awating an ack.  Entries are removed when the ack 
> >    arrives.  This means a per-xprt lock for the queue, and taking a per
> >    bucket lock for each entry we need to remove.
> >    When the xprt closes, everything needs to be moved to the third
> >    queue.
> > 3/ a second per-bucket LRU much like the first one but with a much
> >    longer timeout - several hours.  This is where entries go when
> >    the xprt is closed.  If a new request arrives which matches the
> >    entry, it is moved to the relevant per-xprt LRU.  Probably it is
> >    removed from this LRU, then added to the per-xprt one when it is
> >    sent ... maybe.
> >
> > I had concerns about the changes you made to the LRU code - not a
> > concrete sense of a problem, but more a sense that I couldn't understand
> > what was happening enough to know if there was a problem.
> > I think the above design, particularly keeping the old LRU as-is and
> > adding new LRUs for new needs, addresses those concerns.
> 
> You're jumping ahead of me a little. The next series I have in
> this area implements per-xprt DRCs for connected transports,
> and it provides some of what you describe above.
> 
> So shall I post a v5 that includes that work, or do you think
> merging the v4 work now (with adjustments) is acceptable?

I don't think the intermediate LRU makes any sense.
The change to the eviction walk to only 4 times the maximum number to
free is arbitrary and unjustified.
I understand that for evicting acknowledged replies you need to move
past unacknowledged replies (for another transport), and that you are
cautious about walking the whole list because you don't have control of
the length, but the "4 times" doesn't even seem like good intermediate
solution, and certainly not a good final solution.

If you want to keep the per-xprt LRU for a separate series (and I
understand the appeal of that), I would rather you leave the LRU alone,
only adding the extra "acknowledged replies can be freed if you happen
to find them" case without changing how the LRU is handled in general.
The commit which adds this case would include a note that this will miss
a lot of replies, but that future work will change the LRU.

The removal of the hard cap is, I think, independent of the other
changes - is that right?  In that case I would probably put is first to
make this clear.

Thanks,
NeilBrown


> 
> 
> -- 
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
> 

