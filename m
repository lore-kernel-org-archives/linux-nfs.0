From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] rpc: bring back cl_chatty
Date: Wed, 09 Apr 2008 15:45:13 -0400
Message-ID: <1207770314.11881.13.camel@heimdal.trondhjem.org>
References: <20080408204856.GA21966@fieldses.org>
	 <C3EA9DD1-FA3D-44E0-BCC2-52A0E933FA31@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org,
	aglo@citi.umich.edu
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53551 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752389AbYDITpR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Apr 2008 15:45:17 -0400
In-Reply-To: <C3EA9DD1-FA3D-44E0-BCC2-52A0E933FA31@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-04-09 at 15:01 -0400, Chuck Lever wrote:
> On Apr 8, 2008, at 4:48 PM, J. Bruce Fields wrote:
> > From: Olga Kornievskaia <aglo@citi.umich.edu>
> >
> > The cl_chatty flag alows us to control whether a given rpc client  
> > leaves
> >
> > 	"server X not responding, timed out"
> >
> > messages in the syslog.  Such messages make sense for ordinary nfs
> > clients (where an unresponsive server means applications on the
> > mountpoint are probably hanging), but not for the callback client  
> > (which
> > can fail more commonly, with the only result just of disabling some
> > optimizations).
> >
> > Previously cl_chatty was removed, do to lack of users; reinstate  
> > it, and
> > use it for the nfsd's callback client.
> 
> Actually, this might be another candidate for "fail the request  
> immediately if the transport can't connect."

The fact that you can connect to the server doesn't permit you to assume
that your RPC call will be processed in a timely fashion. While I agree
that the callback client can benefit from the "fail if the transport
can't connect" capability, it isn't a substitute for cl_chatty.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
