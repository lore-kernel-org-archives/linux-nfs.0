From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: high latency NFS
Date: Mon, 04 Aug 2008 16:42:54 +1000
Message-ID: <4896A4EE.9030706@melbourne.sgi.com>
References: <200807241311.31457.shuey@purdue.edu>    <20080730192110.GA17061@fieldses.org>    <4890DFC7.3020309@cse.unsw.edu.au>    <200807302235.50068.shuey@purdue.edu>    <20080731031512.GA26203@fieldses.org>    <18577.25513.494821.481623@notabene.brown>    <20080801072320.GE6201@disturbed> <20080801191559.GI7764@fieldses.org>    <20080804003206.GB6119@disturbed> <52873.192.168.1.70.1217813385.squirrel@neil.brown.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>,
	Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:36880 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755547AbYHDGuI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2008 02:50:08 -0400
In-Reply-To: <52873.192.168.1.70.1217813385.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown wrote:
> On Mon, August 4, 2008 10:32 am, Dave Chinner wrote:
>   
>>>> i.e. take the solution that Greg banks used for the CPU scheduler
>>>> overload issue (limiting the number of nfsds woken but not yet on
>>>> the CPU),
>>>>         
>
> Ahh... I remembered Greg talking about that, went looking, and
> couldn't find it.  I couldn't even find any mail about it, yet I'm
> sure I saw a patch..
>   
http://marc.info/?l=linux-nfs&m=115501004819230&w=2
> Greg: Do you remember what happened to this?  Did I reject it for some
> reason, or did it never get sent?  or ...
>   
I think we got all caught up arguing about the other patches in the
batch (the last round of the everlasting  "dynamic nfsd management for
Linux" argument) and between us we managed to drop the patch on the ground.

http://thread.gmane.org/gmane.linux.nfs/10372

I think the only part of that patchset that you explicitly rejected was
the one where I tried to kill off the useless "th" line in
/proc/net/rc/nfsd.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

