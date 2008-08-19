From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: use of non-privileged ports for MNT and NLM
Date: Tue, 19 Aug 2008 19:44:42 -0400
Message-ID: <1219189482.7150.6.camel@localhost>
References: <0CD0CE08-CB11-419A-9AAC-DEB1AC2B26B3@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bruce Fields <bfields@citi.umich.edu>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19081 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752530AbYHSXpY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2008 19:45:24 -0400
In-Reply-To: <0CD0CE08-CB11-419A-9AAC-DEB1AC2B26B3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-08-19 at 17:14 -0400, Chuck Lever wrote:
> Working on "resvport" mount option.  Question occurred to me:
> 
> If I specify "noresvport" on a mount, can the client also use a non- 
> privileged port for the initial MNT request, and can it use it for the  
> NLM connection as well?
> 
> Question applies not just to Linux servers, but servers in general.   
> Brief searching on teh internets does not reveal a quick answer.  I  
> think rpc.mountd will allow a non-privileged port for "insecure"  
> exports.
> 
> I think the answer is "yes, non-privileged ports can be used for MNT  
> and NLM if the server explicitly allows it" but I thought I would open  
> this up to the list.

How about a default that tries to connect using an insecure port first,
then falls back to a secure port if the attempt fails?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
