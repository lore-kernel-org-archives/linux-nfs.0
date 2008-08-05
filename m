From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: high latency NFS
Date: Tue, 05 Aug 2008 20:51:03 +1000
Message-ID: <48983097.7040100@melbourne.sgi.com>
References: <20080730192110.GA17061@fieldses.org> <4890DFC7.3020309@cse.unsw.edu.au> <200807302235.50068.shuey@purdue.edu> <20080731031512.GA26203@fieldses.org> <18577.25513.494821.481623@notabene.brown> <20080801072320.GE6201@disturbed> <20080801191559.GI7764@fieldses.org> <20080804003206.GB6119@disturbed> <52873.192.168.1.70.1217813385.squirrel@neil.brown.name> <4896A4EE.9030706@melbourne.sgi.com> <20080804190715.GJ25940@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NeilBrown <neilb@suse.de>, Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>,
	Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:41651 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753772AbYHEK6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2008 06:58:24 -0400
In-Reply-To: <20080804190715.GJ25940@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Mon, Aug 04, 2008 at 04:42:54PM +1000, Greg Banks wrote:
>   
>> http://thread.gmane.org/gmane.linux.nfs/10372
>>
>>     
>
> Looks like that was me, apologies.  Breaking a documented interface to
> userspace just set off an alarm.  But if we really convince ourselves
> that it's useless, then OK.
>   
I think I explained last time how useless it is.
> (Though maybe your idea of leaving the line in place with just constant
> zeros is good.  Just because the data's useless doesn't mean someone out
> there may have a script that does otherwise useful things but that
> happens to fail if it can't parse /proc/net/rpc/nfsd.)
>   
Ok, I'm happy to do it that way.
> Looks like it's been two years now--any chance of rebasing those patches
> and resending?
>   
Yep.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

