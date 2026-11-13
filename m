Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.104.188.4
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794530252;
	b=V33a0iT2D9+470ylBsiiWdN2J4bQZAf//MIyjEGE0uBTHwQdxFhAeuB0dtOsom2VcYuL
	 Wh68m/UI7F4n0HY8kfNZxtCeCLseEBxZKTZd3ls+z7pjlRUL12lePYsJzq6Qb/l01w3qJ
	 RJXKCdwB57HgqmNGgB7oAiP1K6OFrwEv2DPZc6kq/yZxR+i4BXqdNGB4a8n7yjQ7uxyZ7
	 d+h9m6XfQWLcs5yMJMGhMqcdIn7jL/0Wgo3WjvO+w5u/QhJ6/duJa5BjIfUR8HPFhMqCE
	 dkOv3BHsp2aH7gFM8gUBW2XXYjpUAyhXyHmkrjmlSjfJb+g1AiESi1rNzTW0tBkSVIg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794530252;
	h=DMARC-Filter:Received:Received:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 X-Spam-Status:X-Spam-Checker-Version;
	bh=fZeMFX6Sitm2JOQVaGbJERpx2uJOFy+G5V29NoE50oE=;
	b=vkHAC5CPoVmPcFjTyYpsYiPDe+OGqvg+0jT1WAhx6bKZhJOE8C+2m4Yp4b2KHXEYj0Fz
	 y4NNc9wXOOQPvVGRzioYJ3Se8SSsaCm/d9A/GeLlUzM82DFOFMgJmXaa5d9/IlLskNj4J
	 QckFzsMJGtb+c5B/I0fYDmTA5yDEkvb8T2pbE5aC+7btc6fWlw0WOVc8SN5Bm/Y6XY3ZB
	 iHTbmJZ2FnafOgTNFW+B5Evkjgp9RgNhJbRDxnFMyh9/xdEOHmQV6xGLo8YjHkaE5saZc
	 2PbILbMh52iRQ4sSTUwzoDxqhltaJqU7ymZUT8cR2ZcEofRkD87BJSwRzspPWh9ahTg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=m5p.com;
	spf=pass smtp.mailfrom=m5p.com;
	arc=none smtp.remote-ip=74.104.188.4
Received: from mailhost.m5p.com (mailhost.m5p.com [74.104.188.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 48C1B606B566
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 00:37:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 48C1B606B566
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=m5p.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=m5p.com
Received: from m5p.com (mailhost.m5p.com [IPv6:fdc4:6ee8:648f:6bf6:0:0:0:f7])
	by mailhost.m5p.com (8.18.1/8.17.1) with ESMTPS id 6AD0aiu3063697
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NO);
	Thu, 12 Nov 2026 19:37:10 -0500 (EST)
	(envelope-from ehem@m5p.com)
Received: (from ehem@localhost)
	by m5p.com (8.18.1/8.15.2/Submit) id 6AD0aiPn063696;
	Thu, 12 Nov 2026 16:36:44 -0800 (PST)
	(envelope-from ehem)
Date: Thu, 12 Nov 2026 16:36:44 -0800
From: Elliott Mitchell <ehem+debian@m5p.com>
To: Salvatore Bonaccorso <carnil@debian.org>
Cc: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>,
        1151866@bugs.debian.org
Subject: Re: Bug#1151866: nfs-common: host= setting in nfs.conf inadaquate
Message-ID: <avZbnBDUZdwgzSIv@mattapan.m5p.com.>
References: <atwPkawUy68vuesl@mattapan.m5p.com.>
 <auLmYFzpKg58BUKW@eldamar.lan>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <auLmYFzpKg58BUKW@eldamar.lan>

On Thu, Oct 29, 2026 at 07:23:28AM +0100, Salvatore Bonaccorso wrote:
> 
> On Fri, Oct 23, 2026 at 06:53:21PM -0700, Elliott Mitchell wrote:
> > Package: nfs-common
> > Version: 1:2.8.3-1
> > 
> > The "host=" setting in /etc/nfs.conf isn't fit for the function it needs
> > to perform.  Of note it doesn't allow binding to multiple addresses.  It
> > also doesn't allow restricting to binding IPv4-only nor IPv6-only.  In
> > fact I was unable to get it to restrict IPv6 binding at all.
> > 
> > Multiple addresses is a common configuration.  Disabling IPv4 or IPv6
> > are also common.
> > 
> > It also appears stopping/starting `/etc/init.d/nfs-kernel-server` appears
> > to leave old address bindings in place.  If the "host=" setting is added,
> > then the daemon is restarted it will remain bound to the wildcard
> > address.
> > 
> > NFS is a service which should be filtered at firewalls, but it should
> > still be possible to restrict binding as a backup security measure.  I'm
> > tempted to rate this as pretty high importance.
> 
> Thanks for your report. Those are rather questions and issues to bring
> to upstream. Can you report them to upstream via the linux-nfs
> mailinglist (linux-nfs@vger.kernel.org) and please include as well
> both Steve Dickson <steved@redhat.com> directly and this Debian
> downstream bugreport, so we can keep track.

Hopefully more than enough in the initial message.

Restarting the kernel nfs server doesn't remove old bindings.

The host= directive appears to only work for a single IPv4 host.

It should be possible to be IPv4-only on a dual-stack computer.  It
should be possible to be IPv6-only on a dual-stack computer.

I guess I should also add I could imagine someone wanting to bind to
different ports on different addresses.




I could see allowing multiple "host=" lines (single entry per).

I could see using commas to separate entries on a single "host=" line.

I could see using spaces to separate entries on a single "host=" line.

I could see allowing multiple of those.


-- 
(\___(\___(\______          --=> 8-) EHM <=--          ______/)___/)___/)
 \BS (    |         ehem+sigmsg@m5p.com  PGP 87145445         |    )   /
  \_CS\   |  _____  -O #include <stddisclaimer.h> O-   _____  |   /  _/
8A19\___\_|_/58D2 7E3D DDF4 7BA6 <-PGP-> 41D1 B375 37D0 8714\_|_/___/5445


