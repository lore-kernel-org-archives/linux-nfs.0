From: Ian Kent <raven@themaw.net>
Subject: Re: Re: [RFC] Multiple server selection and replicated mount
	failover
Date: Wed, 24 May 2006 22:31:35 +0800
Message-ID: <1148481095.8182.29.camel@raven.themaw.net>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
	 <Pine.LNX.4.64.0605241240200.3730@raven.themaw.net>
	 <44745972.2010305@redhat.com> <1148478346.8182.22.camel@raven.themaw.net>
	 <44746803.9000909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FiuOq-0002ns-Mq
	for nfs@lists.sourceforge.net; Wed, 24 May 2006 07:31:48 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FiuOq-0002H6-Is
	for nfs@lists.sourceforge.net; Wed, 24 May 2006 07:31:48 -0700
Received: from ihug-mail.icp-qv1-irony2.iinet.net.au ([203.59.1.196] helo=mail-ihug.icp-qv1-irony2.iinet.net.au)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FiuOq-0007o6-Cf
	for nfs@lists.sourceforge.net; Wed, 24 May 2006 07:31:48 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <44746803.9000909@redhat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, 2006-05-24 at 10:04 -0400, Peter Staubach wrote:
> Ian Kent wrote:
> 
> >
> >Of course, like #1 but with the benefits of #2 without the clutter. I
> >guess all I would have to do then is the vfs mount to make it happen.
> >Are we assuming a restriction like all the mounts have the same path
> >exported from the server? mtab could get a little confused.
> >
> >  
> >
> 
> I don't think that this needs to be restricted like this.  I think that
> it would be nice if mtab just showed the arguments which were used to
> the mount command, ie. with all of the server and path combinations listed
> just like they were on the command line or in the autofs map.
> 
> 
> >But I'm not supposed to peek at that am I (cough, splutter, ...)?
> >
> >  
> >
> 
> Yes, I know.  I am trying to figure out how much of the architecture and
> implementation that I can talk about too...  :-)
> 
> >Cool. That's the way the selection code I have works, except for the
> >kernel bit of course.
> >
> >  
> >
> 
> Good news!

It's in autofs 5 now. The idea is that it will work for any mount
string, replicated syntax or not. So there's no extra mucking around.

I hope to push it into mount and provide a configure option to disable
it in autofs if mount can do it instead.

> 
> >Yep. Failing over the locks looks like it could turn into a nightmare
> >really fast. Sounds like a good simplifying restriction for a first stab
> >at this.
> >
> >  
> >
> 
> Agreed.
> 
> >Interesting. This hadn't occurred to me yet.
> >
> >I was still at the stage of wondering whether the "on demand" approach
> >would work but the simplifying restriction above should make it workable
> >(I think ....).
> >
> >  
> >
> 
> I think that simple is good.  We can always get more complicate later, if
> need be.  (Hope not...  :-) )
> 
> >>The key ingredient to this approach, I think, is a list of servers and
> >>information about them, and then information for each active NFS inode
> >>that keeps track of the pathname used to discover the file handle and
> >>also the server which is being currently used by the specific file.
> >>    
> >>
> >
> >Haven't quite got to the path issues yet.
> >But can't we just get the path from d_path?
> >It will return the path from a given dentry to the root of the mount, if
> >I remember correctly, and we have a file handle for the server.
> >
> >But your talking about the difficulty of the housekeeping overall I
> >think.
> >
> >  
> >
> 
> Yes, I was specifically trying to avoid talking about how to manage the
> information.  I think that that is an implementation detail, which is
> better left until after the high level architecture is defined.

Yep.

> 
> 
> >>    Thanx...
> >>    
> >>
> >
> >Thanks for your comments.
> >Much appreciated and certainly very helpful.
> >
> 
> You're welcome.
> 
> I can try to talk more about the architecture and implementation that I am
> familiar with, if you like.

Any and all information is good.
Food for thought will give me something to eat!

Ian



-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
