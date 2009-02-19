Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:32876 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751556AbZBSHHo (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 19 Feb 2009 02:07:44 -0500
Message-ID: <499D047D.7020102@sgi.com>
Date: Thu, 19 Feb 2009 18:04:29 +1100
From: Greg Banks <gnb@sgi.com>
To: Kevin Constantine <Kevin.Constantine@disneyanimation.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS ML <linux-nfs@vger.kernel.org>,
        Harshula Jayasuriya <harshula@sgi.com>
Subject: Re: [patch 3/3] knfsd: add file to export stats about nfsd pools
References: <20090113102633.719563000@sgi.com> <20090113102653.884405000@sgi.com> <20090212171106.GB21445@fieldses.org> <4994D290.3020906@disney.com>
In-Reply-To: <4994D290.3020906@disney.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Kevin Constantine wrote:
> On 02/12/09 09:11, J. Bruce Fields wrote:
>>
>>
>> As you said, an important question for the sysadmin is "should I
>> configure more nfsds?"  How do they answer that?
>>
>
> I typically use the "th" line to determine whether to add more threads
> or not by looking at the distribution of values across the histogram.
> If things are weighted more towards the 90-100% group, I'll add more
> threads and watch the traffic patterns.
That seems to have been more or less the idea behind the histogram. 
However, to get any useful indication you first need to rate-convert the
histogram.  The values are counters of jiffies which wrap every million
seconds (11.6 days) and there's no way to zero them.

Also, at a call rate above 1/jiffy (a trivially low NFS load) most of
the updates are adding 0 to the histogram.  Every now and again a call
will cross a jiffy boundary and actually add 1 to the histogram.  If
your load is high but not steady, the number of threads busy when that
happens is unpredicable.  In other words there's a sampling effect which
could in the worst case make the values in the histogram be more or less
completely random.

>
> Usually, the question of how many to add is answered by trial and error.
>
> echo 32 > /proc/fs/nfsd/threads
> Did that improve my throughput? yes?
> echo 128 > /proc/fs/nfsd/threads
> Did that improve my throughput? no it actually decreased.
> rinse... repeat...

This procedure is what I would recommend admins do today, assuming their
load is steady or reproducable.  It's not only simple, but it uses a
real-world performance measure, which is "does my application go
faster?".  There's no point adding nfsds if you're limited by the
application, or some filesystem effect that causes the same load to go
slower.  It is of course rather tedious :-)

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

