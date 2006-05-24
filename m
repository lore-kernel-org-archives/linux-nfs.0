From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] Re: [RFC] Multiple server selection and replicated mount
 failover
Date: Wed, 24 May 2006 10:04:51 -0400
Message-ID: <44746803.9000909@redhat.com>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>	 <Pine.LNX.4.64.0605241240200.3730@raven.themaw.net>	 <44745972.2010305@redhat.com> <1148478346.8182.22.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	autofs mailing list <autofs@linux.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Ian Kent <raven@themaw.net>
In-Reply-To: <1148478346.8182.22.camel@raven.themaw.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Ian Kent wrote:

>
>Of course, like #1 but with the benefits of #2 without the clutter. I
>guess all I would have to do then is the vfs mount to make it happen.
>Are we assuming a restriction like all the mounts have the same path
>exported from the server? mtab could get a little confused.
>
>  
>

I don't think that this needs to be restricted like this.  I think that
it would be nice if mtab just showed the arguments which were used to
the mount command, ie. with all of the server and path combinations listed
just like they were on the command line or in the autofs map.


>But I'm not supposed to peek at that am I (cough, splutter, ...)?
>
>  
>

Yes, I know.  I am trying to figure out how much of the architecture and
implementation that I can talk about too...  :-)

>Cool. That's the way the selection code I have works, except for the
>kernel bit of course.
>
>  
>

Good news!

>Yep. Failing over the locks looks like it could turn into a nightmare
>really fast. Sounds like a good simplifying restriction for a first stab
>at this.
>
>  
>

Agreed.

>Interesting. This hadn't occurred to me yet.
>
>I was still at the stage of wondering whether the "on demand" approach
>would work but the simplifying restriction above should make it workable
>(I think ....).
>
>  
>

I think that simple is good.  We can always get more complicate later, if
need be.  (Hope not...  :-) )

>>The key ingredient to this approach, I think, is a list of servers and
>>information about them, and then information for each active NFS inode
>>that keeps track of the pathname used to discover the file handle and
>>also the server which is being currently used by the specific file.
>>    
>>
>
>Haven't quite got to the path issues yet.
>But can't we just get the path from d_path?
>It will return the path from a given dentry to the root of the mount, if
>I remember correctly, and we have a file handle for the server.
>
>But your talking about the difficulty of the housekeeping overall I
>think.
>
>  
>

Yes, I was specifically trying to avoid talking about how to manage the
information.  I think that that is an implementation detail, which is
better left until after the high level architecture is defined.


>>    Thanx...
>>    
>>
>
>Thanks for your comments.
>Much appreciated and certainly very helpful.
>

You're welcome.

I can try to talk more about the architecture and implementation that I am
familiar with, if you like.

       ps
