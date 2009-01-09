From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [patch 00/14] sunrpc: Sunrpc cache cleanups and upcall rework
Date: Fri, 09 Jan 2009 12:42:29 +1100
Message-ID: <4966AB85.1070105@melbourne.sgi.com>
References: <20090108082510.050854000@sgi.com> <20090108195158.GA19312@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:44881 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751384AbZAIBuT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 20:50:19 -0500
In-Reply-To: <20090108195158.GA19312@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Jan 08, 2009 at 07:25:10PM +1100, Greg Banks wrote:
>   
>> These patches are a snapshot of in-progress work
>>     
>
> That sounds suspiciously like "do not apply!". 
On these patches, it's your call.

When I say "in-progress" I really mean that these haven't shipped in an
SGI product. There are more patches in this same series, not yet posted,
which are definitely in the "do not apply" category and which I will
mark as such when they appear.

For the latter (logic-changing) patches, I can report that they've had
the same amount of testing that most Linux patches claim to have
received.  In other words they worked fine on one architecture, with the
obvious publicly available testsuite, with a small client count, with
light load levels, and no data corruption testing, and no point
regression test for the bug being fixed.  I've seen code checked into
Linux with less testing.

OTOH these patches have not been through an SGI QA cycle, and given the
circumstances it seems unlikely they will.  So I would not ship these in
an SGI product yet.

Your call.  I would be comfortable with these patches going into 2.6.30.

>  I may as well queue up
> the first 6 for 2.6.30, though?
>   
Yes, the first 6 make no logic changes and I believe they are quite
harmless.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

