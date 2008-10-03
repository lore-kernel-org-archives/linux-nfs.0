From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/7] NLM: Convert nlm_lookup_host() to use a single
	argument
Date: Fri, 03 Oct 2008 13:39:40 -0400
Message-ID: <1223055580.8111.1.camel@localhost>
References: <20081003162856.10198.20451.stgit@ingres.1015granger.net>
	 <20081003165006.10198.9012.stgit@ingres.1015granger.net>
	 <1223054162.7346.1.camel@localhost>
	 <51B54FBE-A322-4561-BCEC-AB805DE3BB06@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:43356 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197AbYJCRjr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Oct 2008 13:39:47 -0400
In-Reply-To: <51B54FBE-A322-4561-BCEC-AB805DE3BB06@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-10-03 at 13:33 -0400, Chuck Lever wrote:
> >> +#define NLM_SERVER	(0)
> >> +#define NLM_CLIENT	(1)
> >> +
> >
> > Could we please get RID of this crap instead of 'documenting' it?  
> > There
> > is absolutely _no_ excuse for keeping a single list for both server  
> > and
> > client struct hosts...
> >
> > Strongly NACKED....
> 
> We haven't dropped that work item, but Bruce and I agreed months ago  
> that he would handle the client/server list split *after* I had  
> finished the IPv6 changes.  I think the IPv6 work is a much higher  
> priority here.

Then please don't throw in unnecessary trivia that can confuse people.

