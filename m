From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [pnfs] [RFC 0/4] nfs-utils: nfsd support for minor version
Date: Fri, 17 Apr 2009 08:35:36 -0400
Message-ID: <49E87798.8090308@RedHat.com>
References: <49E2F6E4.2080501@panasas.com> <49E769C5.6010902@RedHat.com> <49E7721E.2070601@panasas.com> <49E7753C.4010300@RedHat.com> <20090416182313.GE450@fieldses.org> <49E7809B.2020002@RedHat.com> <20090416191826.GC1145@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41252 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760839AbZDQMkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Apr 2009 08:40:31 -0400
In-Reply-To: <20090416191826.GC1145@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Apr 16, 2009 at 03:01:47PM -0400, Steve Dickson wrote:
>> I do get your point, but as we did with the initial v4 support, 
>> having the support on by default and then having away to turn it
>> off is the correct approach... IMHO... 
> 
> I'd prefer it be off by default, for the obvious safety reasons.  (It's
> under rapid development and particularly likely to have bugs).  The only
> reason we had it on by default before was that we didn't add the
> switching mechanism early enough.  (Well, and because we could keep it
> off in the config.  But I'd rather be able to ship users a kernel that
> supports 4.1 and give them the option of turning it on at runtime, than
> make them build a new kernel.)
I agree with not making people recompile kernels, which is the whole
purpose behind the Fedora repos, but do I think you might be a bit 
too cautious with exposing the technology. 

One, I've been running the kernels with everything enabled for a while
now with no problems whatsoever... A few scary looking warnings now and
then but nothing major. I also spent the majority of my time at Connectathon
this years testing with kernel that were fully enabled. Not one problem
WRT regression testing. Plus there is no better way to expose regression 
problems (early on) than to enable the code.. IMHO... 

Second, its my understanding that clients have to explicitly  ask
for 4.1 support. Are there any client out there that default to 
4.1 support? I would think not since there is only one client out there
that defaults to V4.0. If there is a client that defaults to 4.1, then we 
will a knob to turn that support off.

Finally, with rpc.nfsd the precedence has already been set that we disable
versions, not enabled them. For us to start enabling versions with rpc.nfsd
we would have to come up with another command line flags (similar to Benny's
patch). This means we would have one flag that enables versions and 
another that would disable them... talk about confusion... and that's just
not right... IMHO.... 

So I say, lets stay with the precedence that was already set, enable
the support by default but have a way to disable it... 

steved.



   
