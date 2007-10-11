From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 06/12] text-based mount.nfs:
Date: Thu, 11 Oct 2007 11:32:11 +1000
Message-ID: <18189.32027.462332.151295@notabene.brown>
References: <20071008155407.15051.60775.stgit@manray.1015granger.net>
	<18186.56139.301135.961540@notabene.brown>
	<5847045D-72E9-4322-AB08-F8952C26AA44@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfmuQ-0001zm-SE
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 18:32:18 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfmuT-0006It-Ii
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 18:32:24 -0700
In-Reply-To: message from Chuck Lever on Tuesday October 9
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tuesday October 9, chuck.lever@oracle.com wrote:
> >>  /*
> >> + * Reconstruct the mount option string based on a portmapper probe
> >> + * of the server.  Returns one if the server's portmapper returned
> >> + * something we can use, otherwise zero.
> >> + *
> >> + * Unfortunately, for fallback, we need to parse out the mount  
> >> options
> >> + * in user space.  Unrecognized options are ignored here.
> >
> > (I that paragraph of the comment still relevant?)
> 
> I'm not sure what you think is irrelevant... the bit about  
> unrecognized options?  If so, that comment was meant to imply that as  
> we add support for new mount options in the kernel, we needn't be too  
> concerned about adding support for them here as well.
> 
> Or maybe you meant the "need to parse out the mount options in user  
> space" -- that implies that, for text-based mounts, mount.nfs still  
> needs to parse the mount options in order to do the port probe and  
> then rewrite them.  Our dream of parsing only in the kernel is dashed  
> on the rocks.

The comment talks about parsing out the mount options, which is now
done in a very different part of the code.
And I misread the "Unrecognised options are ignored here" as saying that
they get removed... Maybe the "unfortunately" predisposed me to think
something bad?

> 
> I will see about clarifying that when resubmitting the patch.

Yes, new version much clearer, thanks.

> > By the by, when testing what the current code does, I discovered that
> > if
> >
> >       mount server:/path /dir
> >
> > falls back to v2 because the default (v3) doesn't work, then
> >      umount /dir
> >
> > fails with
> >
> >      umount.nfs: Server failed to unmount 'server:/path'
> >
> > which is a worry.
> 
> OK, it's not supposed to do that either, and I never saw that  
> behavior during testing.  (Well, actually we did see it, but it was  
> only with NFSv4, and is supposed to be fixed by one of the patches in  
> the last set I sent you).
> 
> > I think there are two problem here:
> >   1/ we should fall back to v2 umount if v3 fails (well, the MOUNT
> >      versions  are different, but you know what I mean).
> >   2/ If the call to the server fails, we should still unmount the
> >      filesystem (call del_mtab .... not a good choice for the name
> >      of the function that does the actual unmount...)
> > Thoughts?
> 
> First I would like to understand precisely why umount is failing.  In  
> this case, mount.nfs should rewrite the mount options, then post them  
> in /etc/mtab so that umount can use the same service endpoint when  
> doing the unmount.  The umount should then use the post-fallback  
> options, and succeed.  Does "umount -v" provide any helpful
> information?

(remembering this is with the binary mount interface, not the new
ASCII one) the updated mount options are *not* written to /etc/mtab.
It just has 

 eli:/var/tmp/samba /mnt nfs rw,addr=192.168.1.3 0 0

nfsvers=2 has not been added.
umount -v says:
umount.nfs: trying 192.168.1.3 prog 100005 vers 3 prot UDP port 723
umount.nfs: Server failed to unmount 'eli:/var/tmp/samba'


> 
> Certainly it would be good to rename del_mtab() !
> 
> I also agree that it would be an overall improvement if the RPC  
> umount request did not determine whether or not umount also tries to  
> detach the local file system.  I don't see any good reason to link  
> the two.

I've broken the link, so the unmount now succeeds.  It would be good
to get it to send the right request to the server though, either by
recording the protocol in mtab, or using probe_mntport or similar.

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
