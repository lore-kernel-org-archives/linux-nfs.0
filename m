Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:52179 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755472AbZCLQPY (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 12 Mar 2009 12:15:24 -0400
Message-ID: <49B9360F.9060903@sgi.com>
Date: Fri, 13 Mar 2009 03:19:27 +1100
From: Greg Banks <gnb@sgi.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Kevin Constantine <Kevin.Constantine@disneyanimation.com>,
        linux-nfs@vger.kernel.org
Subject: Re: nfsstat --sleep=#
References: <49B86744.6060105@disney.com> <ADDF97BC-8B6A-4EFC-9242-C1454B8F423C@oracle.com>
In-Reply-To: <ADDF97BC-8B6A-4EFC-9242-C1454B8F423C@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:
> Hi Kevin-
>
> man watch(1)
Watch + today's nfsstat isn't smart enough to tell you deltas, or do
rate conversion.  However...

http://oss.sgi.com/projects/pcp/
 
PCP includes a gui tool which gives you rate conversion and graphical
presentation with history and automatic scaling of any metrics.  Plus
you can do archive recording and playback, and remote access. Supported
metrics include the existing server stats (but not the client-side
per-server stats).

In the absence of a useful tool like PCP, some time ago I did write a
patch add some of those features (rate conversion in particular) to
nfsstat.  The patch gives nfsstat a mode where it behaves like "vmstat
1" or "iostat 1", i.e. textually reports deltas or rates continuously in
a loop with a controllable interval.  I dug it up earlier today but
unfortunately it won't apply anymore (due to changes for the
implementation of the --sleep mode).  I won't have time to work on it
just now, but I can post it if anyone cares to mine it for ideas.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

