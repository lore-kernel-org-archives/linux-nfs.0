From: Greg Banks <gnb@sgi.com>
Subject: Re: nfsstat --sleep=#
Date: Thu, 12 Mar 2009 12:58:13 +1100
Message-ID: <49B86C35.3030800@sgi.com>
References: <49B86744.6060105@disney.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:50973 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754525AbZCLByG (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 21:54:06 -0400
In-Reply-To: <49B86744.6060105-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kevin Constantine wrote:
> I'd really like to have a way to output the nfsstat counters at
> regular intervals (every 3 seconds) where the output is the difference
> between 3 seconds ago and now.  Frequently I'll run a test and want to
> watch the nfs call profile throughout the course of the test.
>
> Does something like this already exist?
> Are there objections to seeing a feature like this?

I wrote some patches a couple of years back to do that.  I'll see if I
can dig 'em up.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

