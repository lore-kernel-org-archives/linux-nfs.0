From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 06/12] text-based mount.nfs:
Date: Tue, 9 Oct 2007 09:51:10 -0400
Message-ID: <5847045D-72E9-4322-AB08-F8952C26AA44@oracle.com>
References: <20071008155407.15051.60775.stgit@manray.1015granger.net>
	<18186.56139.301135.961540@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfFUZ-00023F-US
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 06:51:23 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfFUe-0003KL-Ts
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 06:51:29 -0700
In-Reply-To: <18186.56139.301135.961540@notabene.brown>
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

Yep, this is the one I thought we would noodle on a bit to get it right.

On Oct 8, 2007, at 9:37 PM, Neil Brown wrote:
> First 5 OK and applied.  But I'm a bit uncertain about this one.
> I think the rest are OK as well, so once we've sorted this one, the
> rest can be applied.
>
> Apart from the empty subject line :-), it doesn't look right.

I tried to be careful.  The fallback behavior with text-based mounts  
is an attempt to be bug-for-bug compatible with legacy mount  
behavior.  So the starting place is to see what mount.nfs does in the  
same situation on the 2.6.22 kernel.

> In particular....
>
> On Monday October 8, chuck.lever@oracle.com wrote:
>> Introduce a function for probing the server for what it supports,  
>> and then
>> rewriting the mount options using the probe results.
>
>>  /*
>> + * Reconstruct the mount option string based on a portmapper probe
>> + * of the server.  Returns one if the server's portmapper returned
>> + * something we can use, otherwise zero.
>> + *
>> + * Unfortunately, for fallback, we need to parse out the mount  
>> options
>> + * in user space.  Unrecognized options are ignored here.
>
> (I that paragraph of the comment still relevant?)

I'm not sure what you think is irrelevant... the bit about  
unrecognized options?  If so, that comment was meant to imply that as  
we add support for new mount options in the kernel, we needn't be too  
concerned about adding support for them here as well.

Or maybe you meant the "need to parse out the mount options in user  
space" -- that implies that, for text-based mounts, mount.nfs still  
needs to parse the mount options in order to do the port probe and  
then rewrite them.  Our dream of parsing only in the kernel is dashed  
on the rocks.

I will see about clarifying that when resubmitting the patch.

>> + *
>> + * Order of processing:
>> + * 1.  fill in mnt_server and nfs_server, based on existing options
>
> This statement doesn't seem to be true.
> In particular, the 'version number' and 'proto' in the existing
> options are *not* (that I can see) filled in for nfs_server.

Yes, that's correct.  The idea is that the port probe will fill those  
in for us based on what the server supports.

> So it would seem that
> 	mount -o vers=3  server:/path /dir
>
> would fall back to v2 if 'server' didn't support v3.  I don't think
> that is right (current mount.nfs doesn't do that).

Hrm, I tested that at one point, but this latest version may behave  
incorrectly.  (To be clear, yes, I agree that version fallback should  
occur only if the user did not specify "vers=" or "nfsvers=".   
Likewise for the transport protocol).

Filling in nfs_server based on existing version and protocol options  
will probably prevent this incorrect behavior by nailing the port  
probe to a specific version or protocol, and it's easy enough to add  
that.

> Did I misunderstand the code?

No.  Your review has been helpful at each point.

> By the by, when testing what the current code does, I discovered that
> if
>
>       mount server:/path /dir
>
> falls back to v2 because the default (v3) doesn't work, then
>      umount /dir
>
> fails with
>
>      umount.nfs: Server failed to unmount 'server:/path'
>
> which is a worry.

OK, it's not supposed to do that either, and I never saw that  
behavior during testing.  (Well, actually we did see it, but it was  
only with NFSv4, and is supposed to be fixed by one of the patches in  
the last set I sent you).

> I think there are two problem here:
>   1/ we should fall back to v2 umount if v3 fails (well, the MOUNT
>      versions  are different, but you know what I mean).
>   2/ If the call to the server fails, we should still unmount the
>      filesystem (call del_mtab .... not a good choice for the name
>      of the function that does the actual unmount...)
> Thoughts?

First I would like to understand precisely why umount is failing.  In  
this case, mount.nfs should rewrite the mount options, then post them  
in /etc/mtab so that umount can use the same service endpoint when  
doing the unmount.  The umount should then use the post-fallback  
options, and succeed.  Does "umount -v" provide any helpful information?

Certainly it would be good to rename del_mtab() !

I also agree that it would be an overall improvement if the RPC  
umount request did not determine whether or not umount also tries to  
detach the local file system.  I don't see any good reason to link  
the two.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
