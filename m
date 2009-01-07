From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 17:22:43 -0800
Message-ID: <1231291363.14345.266.camel@localhost>
References: <ae2fa56f38f87da3a90ab6fe39954b2b.squirrel@webmail.uio.no>
	 <1231289847.14345.243.camel@localhost>
	 <1231290153.11487.34.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:36286 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbZAGBW6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 20:22:58 -0500
In-Reply-To: <1231290153.11487.34.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 20:02 -0500, Trond Myklebust wrote:
> On Tue, 2009-01-06 at 16:57 -0800, Matt Helsley wrote:
> > On Tue, 2009-01-06 at 19:39 -0500, trond.myklebust@fys.uio.no wrote:
> > > On Tue, 2009-01-06 at 16:08 -0800, Matt Helsley wrote:
> > > > IMHO This seems more incorrect than trying to use a more proximal
> > > namespace.
> > > 
> > > You have yet to explain why.
> > 
> > Yes, I know I have to explain why. If you would please have a little
> > more patience you might see I have replied to your original request for
> > an explanation -- I *just* sent it out. If I don't see it show up soon
> > I'll resend it as a reply here. OK?
> 
> Sorry if you saw the request twice. My mail server at uio.no appears to
> be on the blink, so I switched to the netapp account...

Ahhh, ok. Sorry I misinterpretted that..

Cheers,
	-Matt Helsley

