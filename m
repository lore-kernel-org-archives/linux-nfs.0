From: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
Subject: Re: [Bug 13034] printk in xs_tcp_setup_socket needs rate limit ...
  and delay
Date: Thu, 23 Apr 2009 09:02:07 +0200
Message-ID: <20090423090207.5d6a1cd9@hyperion.delvare>
References: <bug-13034-104@http.bugzilla.kernel.org/>
	<200904222049.n3MKnxZi019947@demeter.kernel.org>
	<1240433936.9197.9.camel@heimdal.trondhjem.org>
	<49EF9896.2000301@vmware.com>
	<1240447977.9197.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Petr Vandrovec <petr@vmware.com>,
	"bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org"
	<bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org>,
	Petr Vandrovec <petr@vandrovec.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zone0.gcu-squad.org ([212.85.147.21]:18050 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbZDWHDt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 03:03:49 -0400
In-Reply-To: <1240447977.9197.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 22 Apr 2009 20:52:57 -0400, Trond Myklebust wrote:
> Good! The 5minute idle timeout is the one case where we don't care about
> preserving the port number (because there are no outstanding NFS
> requests to replay to the server).
> 
> Jean, are you seeing the same behaviour (i.e. errors only on idle
> timeout), and is the fix working for you?

I didn't hit the problem since I applied your patch, but that was only
yesterday so it's too early to draw statistically valid conclusions.

It is highly possible that the bug was happening on idle timeout, I am
the only user on this machine and I access the NFS mounts only from
times to times.

-- 
Jean Delvare
