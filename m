From: Matt C <wago@phlinux.com>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: Thu, 25 Sep 2003 16:17:54 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309251614290.22478-100000@fubar.phlinux.com>
References: <shsd6dyabju.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Olaf Hering <olh@suse.de>, "H. Peter Anvin" <hpa@zytor.com>,
	Arun Sharma <arun.sharma@intel.com>, <autofs@linux.kernel.org>,
	<nfs@lists.sourceforge.net>, Ian Kent <raven@themaw.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2fNS-0005h3-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 16:18:26 -0700
Received: from fubar.phlinux.com ([216.254.54.154])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2fNR-00061v-Vt
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 16:18:26 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsd6dyabju.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi All-

We've been having the 'VFS: Busy inodes after unmount' problems like crazy 
on our desktop and server linux boxes running autofs under 2.4.21 
(vanilla). We're using the autofs-3.1.7 userspace tools, but with the 
autofs4 kernel module.

I applied the patch that was attached earlier in this thread to our kernel 
and have been running it for the past few days on my desktop. These errors 
have completely disappeared, and autofs is behaving as expected so far.

So, while it might be the wrong thing to do, it does fix our problems.

-matt

On 18 Sep 2003, Trond Myklebust wrote:

> >>>>> " " == Olaf Hering <olh@suse.de> writes:
> 
>      >  On Wed, Sep 17, H. Peter Anvin wrote:
>     >> Okay... let me ask this so I get it straight...
>     >>
>     >> Has anyone seen this (busy inodes after stopping the
>     >> automounter) using autofs v3 kernel module and daemon?
> 
>      > I'm not sure, but everyone who has seen this should fiddle this
>      > patch into the kernel and see how it goes.  The whole thing
>      > started very recently (post 2.4.21) for us.
> 
>      > This patch is untested, any feedback appreciated.
> 
> ...and is indeed wrong... It does the exact opposite of what
> sillydelete should do. Instead of causing the last application that
> closes the file to perform the sillydelete, you are asking the *first*
> application that closes it to do so.
> Sillydelete *has* to be tied to dentries. Not files, and not
> inodes. It is purely a namespace operation...
> 
> So exactly what are you trying to do, and why?
> 
> Cheers,
>   Trond
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
