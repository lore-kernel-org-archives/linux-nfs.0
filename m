Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792515832;
	b=EniUaL66i0DwCisVkAPR0hU1z2pN8t9fyGLAy1XYcKtXjIa9IAZg2/qLHm4/qu26xU1Z
	 8Px/6ZVTObOWDSMQ/4HPXniXvY8zO9Yt8QGk8DgCmSqlV93tYnYlnSfmUUR407TCPD68h
	 50DsDxdPEhxyD3VgMvgo5VdCxjloy5gBDlMAJjn0wjhgNRPphGE/v5KdKRNLtMqAHx+Pn
	 EXPpZA7O8L2kh2u/zmykgV2LgLQURSjgASqT5UXN5c+S0nxhwHlRSwQIilnxMxDdWuZ74
	 6YYqD7rHjJdCVCqhHsB5ikRqYSgK7bniFTA/02aH7NuQl65Vp9edE2o2xV7uzIpWACA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792515832;
	h=Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Type:Content-Transfer-Encoding;
	bh=OnO3sUL+tL/P4D7M/RB/v1+t3Pv2abKUS1M6dTbvBMY=;
	b=pR5VNaS9X5K53IEjH6+IAiufRviyPlMQiNLvCKoY6iG86Jwh3bR/aiL0VEjCiAVZAamV
	 6wUp6gMZVDgXp9e0Me9w0rXRwJ3Idbc9JzMSVPgdjO2HlLochL+IM5oR+/XiQd8VSHFfS
	 ZiMOrqzO6meHkH4exJ6JMBX4AUE85XTIr8aWvu4qWECzG6N41xQPdAhy/ZKO/4UBWegXl
	 CeSIaGf+jaHYks6udutTnRC9OdDWPkvR+GHUwLycH4UbVi+CMlpgQrcPUTVYFQ9zW0Y7u
	 I27oupdcm3BT2MCq+YDoZvxD3SsquFY+gTzbLyWYR93DaebAsdPhk+iKNNejhoz+2rw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B5F9606A319;
	Tue, 20 Oct 2026 17:03:52 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0C9151F000C9;
	Tue, 20 Oct 2026 17:03:50 +0000 (UTC)
From: Chuck Lever <cel@kernel.org>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH draft-v6 1/6] NFSD: add tracing for how direct-mode READ and WRITE are serviced
Date: Tue, 20 Oct 2026 13:03:17 -0400
Message-ID: <179251578815.1375755.11152570607599449216.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <atbfEbgMU6UGkn2X@kernel.org>
References: <atbfEbgMU6UGkn2X@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Mon, 19 Oct 2026 23:25:05 -0400, Mike Snitzer wrote:
> On Mon, Oct 19, 2026 at 02:33:47PM -0400, Chuck Lever wrote:
> > On Mon, Oct 19, 2026, at 11:07 AM, Mike Snitzer wrote:
> > > Add:
> > >
> > >  - nfsd_write_dio_split, emitted once per direct-mode WRITE before any
> > >    segment is issued.  It records the advertised offset and memory
> > >    alignments, the payload's offset within its first page, the start,
> > >    middle and end segment sizes, a disposition naming the path taken
> > >    (direct, no_alignment, too_small, no_middle, mem_misaligned), and
> > >    whether buffered segments are issued IOCB_DONTCACHE.
> >
> > Let's define a single event class and then use DEFINE_EVENT per outcome,
> > rather than one event with a disposition field. You'll notice this
> > pattern is used elsewhere in trace.h.
> >
> > So nfsd_write_dio_class with the alignment and segment-size fields, and
> > nfsd_write_dio_direct, _no_alignment, _too_small, _no_middle,
> > _mem_misaligned fired at the site that makes each decision. An admin
> > chasing "why isn't this direct" then enables only the decline events.
> >
> > Also, let's give the READ side the same treatment so admins can see
> > the decisions that prevent reads from going direct.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/6] NFSD: add tracing for how direct-mode READ and WRITE are serviced
      commit: ad42983b887e9abf7109535a654dbac6cfc3b72b

--
Chuck Lever

