From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [RFC] new client gssd upcall
Date: Thu, 19 Jun 2008 13:06:22 -0400
Message-ID: <1213895182.7120.13.camel@localhost>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
	 <20080616102859.66fa6a34@tleilax.poochiereds.net>
	 <20080617213622.GA5849@fieldses.org> <1213739969.7288.90.camel@localhost>
	 <485A7D2D.4060206@citi.umich.edu>
	 <20080619114929.5c211ec9@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>, kwc@citi.umich.edu,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759437AbYFSRKZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2008 13:10:25 -0400
In-Reply-To: <20080619114929.5c211ec9-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-06-19 at 11:49 -0400, Jeff Layton wrote:
> Because it's less code that we have to maintain. rpc_pipefs certainly works
> (and works fairly well), but we have so many upcall mechanisms in the
> kernel already. keyctl also has some nice features (automated cache
> timeouts, granular security, etc), and was designed with this sort of use
> in mind.
> 
> I'm not saying that we absolutely need to scrap rpc_pipefs, but considering
> alternatives may mean less work for us all in the long run.

Talk about scrapping rpc_pipefs is premature, to say the least: I have
yet to see a plan for replacing the idmapd upcall. I have yet to see
working code that replaces the gss upcall and that works correctly in a
non-blocking environment.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
