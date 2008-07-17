From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Fri, 18 Jul 2008 09:15:17 +1000
Message-ID: <18559.53893.95829.499988@notabene.brown>
References: <18556.40594.897682.204554@notabene.brown>
	<76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Steve Dickson" <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:56514 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756120AbYGQXPT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2008 19:15:19 -0400
In-Reply-To: message from Chuck Lever on Tuesday July 15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday July 15, chuck.lever@oracle.com wrote:
> On Tue, Jul 15, 2008 at 8:56 AM, Neil Brown <neilb@suse.de> wrote:
> > This is the promised patch that adds mountproto=tcp to the string
> > mount options if needed.
> > We still get a 90second timeout, but at least it works rather than
> > saying "mount.nfs: internal error".
> >
> > It seems to me that it would be best to avoid the first call to mount
> > altogether.  Simply always do a probe_both and then do a mount based
> > on the results of that.
> > Is there a good reason not to?
> 
> If I understand the question correctly, I think it doesn't because in
> the most common cases, this isn't necessary.  The mount options are
> usually adequate, and most servers support all the necessary NFS
> versions and transport protocols.  This saves ephemeral ports and uses
> less network traffic.

Yes, I think you understand the question correctly.

Your point about saving ephemeral ports is a strong one.

The "most servers" point is less strong.  If there are any valid uses
were the current code causes unnecessary delays we should try to
address them, even if they are relatively few.

Suppose we were to take this approach:

   mount.nfs does DNS lookup and portmap look to find IP address and
      port number.  However it *doesn't* send a 'clnt_ping' as
      probe_port currently does.
   The information it collects is explicitly given to the kernel with
       mountproto= mountport= etc.
   The kernel talks directly to mountd (given proto/addr/port) to get
      the filehandle and so forth.  It doesn't talk to portmap at all
      if it is given the required port numbers.

This way there is no duplication of effort, but the "try this/try that"
heuristics are all in user-space where they (arguably) belong and
where it is easier to have control over timeouts.

The only case where the above would not easily do the right thing is
when portmap reports a port that the kernel cannot successfully talk
to.  That is really a configuration error (rather than just an
'interesting' configuration).  In that case, mount.nfs could
retry probe_both but this time do the clnt_ping to make sure the
service really is there.

Thoughts?

> >
> > If an NFS server is only listening on TCP for portmap (as apparently
> > MS-Windows-Server2003R2SP2 does), mount doesn't cope.  There is retry
> > logic in case the initial choice of version/etc doesn't work, but it
> > doesn't cope with mountd needing tcp.
> > So:
> >  Fix probe_port so that a TIMEDOUT error doesn't simply abort
> >    but probes with other protocols (e.g. tcp).
> 
> That seems reasonable and will update the behavior for both legacy and
> text-based mounts.
> 
> But should you teach connect_to() to specifically handle ECONNREFUSED
> as well?  I don't see why there would be a long timeout in that case.

I don't think connect_to is the problem.
The (current) problem is when portmap cannot be reached by UDP.
This is attempted in clnt_call called from getport.
This is done over an unconnected socket so ICMP errors don't come back
(I think) so the timeout is all that clnt_call gets to know there is
an error... I wonder what would happen if we just changed that to be a
connected socket...

Thanks,
NeilBrown
