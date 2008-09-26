From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NLM: Revert parts of commit 24e36663
Date: Fri, 26 Sep 2008 18:22:05 -0400
Message-ID: <1222467725.15581.5.camel@localhost>
References: <20080924184732.4078.83334.stgit@tarkus.1015granger.net>
	 <20080925213831.GF14349@fieldses.org>
	 <AED0D581-07B0-4EC6-90AB-2F61B6F3C76B@oracle.com>
	 <20080926184554.GA1492@fieldses.org> <1222454975.10150.8.camel@localhost>
	 <EF58CFE4-3F4B-4985-9DEA-E61CC0DFC8EA@oracle.com>
	 <1222456290.10150.10.camel@localhost> <20080926194421.GD1492@fieldses.org>
	 <87089E47-10AE-4D41-B5BE-CCEE034C526B@oracle.com>
	 <1222459067.10150.16.camel@localhost>
	 <215DBAD9-1E4B-4E23-9F54-AAF6518D24DA@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11913 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752050AbYIZWWk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 18:22:40 -0400
In-Reply-To: <215DBAD9-1E4B-4E23-9F54-AAF6518D24DA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-09-26 at 17:11 -0400, Chuck Lever wrote:
> If I know in advance when you (and Bruce) are taking new features or  
> bug fixes for each kernel release, that would be helpful.

That won't happen.

Send it when it is _ready_. That is the way everyone else works when
doing Linux kernel development...

If it needs to go into a particular kernel release, either because it is
a bugfix for a known problem, or because other patches depend upon it,
then make a special case for that.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
