From: Goutham Kurra <kurrag1@yahoo.com>
Subject: Re: force unmount not working 2.4.22
Date: Mon, 11 Oct 2004 15:09:42 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041011220942.96898.qmail@web20525.mail.yahoo.com>
References: <20041009214156.GV7742@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CH8Ma-0000qk-Ph
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 15:09:52 -0700
Received: from web20525.mail.yahoo.com ([216.136.227.42])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CH8MQ-0007IA-MH
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 15:09:52 -0700
To: Garrick Staples <garrick@usc.edu>, nfs@lists.sourceforge.net
In-Reply-To: <20041009214156.GV7742@polop.usc.edu>
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



I can see that '-f' tries to stop all active rpc tasks
to the server, but I guess the reference counts on the
mount are not dropped. What would be cool is a
'brute-force' option that kills any process that still
holds a reference to the filesystem and then also
unmounts it. 

The problem with using something like fuser is that it
will promptly hang on an unreachable server making it
useless on nfs filesystems. 

Any ideas on what to do in this case (i.e, unreachable
NFS server, plus a bunch of processes hung on the
mount)?

I'm uncomfortable using lazy unmounts as I don't have
a way of knowing if the filesystem has finally been
dropped or not.

goutham


--- Garrick Staples <garrick@usc.edu> wrote:

> On Sat, Oct 09, 2004 at 02:22:31PM -0700, Goutham
> Kurra alleged:
> > 
> > Force unmount simply isn't working on a standard
> linux
> > 2.4.22 kernel. Isn't it supposed to unmount NFS
> > filesystems no matter what?
> > 
> > In my case, the backend server is still up and
> > working, I have a "tail -f /mnt/nfs/foo" of some
> file
> > on the mount, and "umount -f" fails with "device
> or
> > resource is busy"
> 
> I don't believe force is useful in this case, what
> you want is -l.
> 
>    -f     Force unmount (in case of an unreachable
> NFS system).  (Requires
>           kernel 2.1.116 or later.)
> 
>    -l     Lazy unmount. Detach the filesystem from
> the filesystem  hierar-
>           chy now, and cleanup all references to the
> filesystem as soon as
>           it is not busy anymore.  (Requires kernel
> 2.4.11 or later.)
> 
> -- 
> Garrick Staples, Linux/HPCC Administrator
> University of Southern California
> 

> ATTACHMENT part 2 application/pgp-signature 




		
__________________________________
Do you Yahoo!?
Yahoo! Mail Address AutoComplete - You start. We finish.
http://promotions.yahoo.com/new_mail 


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
