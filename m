From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils umount command does not use correct
 TCP/UDP protocol
Date: Tue, 13 Mar 2007 16:20:06 +1100
Message-ID: <17910.13446.136147.462603@notabene.brown>
References: <1173098587.4825.9.camel@LINE> <45F616BA.3030602@nanjing-fnst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, SteveD@redhat.com,
	Amit Gud <agud@redhat.com>
To: Wei Yongjun <yjwei@nanjing-fnst.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQzR0-0007RI-Kg
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 22:20:30 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQzR1-0004KB-8L
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 22:20:32 -0700
In-Reply-To: message from Wei Yongjun on Tuesday March 13
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tuesday March 13, yjwei@nanjing-fnst.com wrote:
> Nobody replied yet, but I think this is really a BUG of umount.nfs command.

Thank you for drawing my attention to this code.  It is rather
..... interesting...

We are given a name (in variable 'spec') on the command line for
something that needs to be unmounted.  It is expected to be either a
path name to the mountpoint, or a host:/remote/path name of what was
mounted.

We then look for that in /etc/mtab or, if that file does not exist or
is empty, in /proc/mounts.  We first look for an entry with the name as
the mountpoint, and then for an entry the name as the remote path,
looking from the end of the file.

So far, so good.

If an entry was found we call _nfsumount passing the remote name
and the options from mtab (or mounts).  The job of _nfsumount is to
tell the server that we don't have it mounted any more.
_nfsumount needs to know what protocol to use and despite having the
option in a string that was passed to it, it calls get_mntproto which
looks in /proc/mounts (or maybe /etc/mtab) for the option.
Why not just use the options that were passed, at least if you have
them?
Odd.

Then, if _nfsumount fails (maybe the server was down) nfsumount() does
*not* call add_mtab2.  So if the server is down, you cannot unmount an
nfs filesystem.  That is a bit sad.

It is also kind-of odd that add_mtab2 does the actual unmount.  You
would think that with a name like that it would at most remove an
entry from mtab...  (I wonder what was wrong with 'del_mtab').

Now, suppose the entry wasn't found in mtab (maybe mtab got corrupted
- stranger things have happened).
In that case the name is given to _nfsumount with NULL as the options.
So _nfsumount needs to depend on the hostname in the name (which won't
be there if you give a local path name...) but goes to /proc/mounts to
find the protocol.  Odd.  If it is going to /proc/mounts, may as well
look there for addr= or mounthost= etc.

And again if _nfsumount fails (guaranteed if a local path was passed)
there is no attempt to unmount the filesystem, or remove it from mtab
(not that it is in mtab... we didn't find it, remember).

There is obviously a lot of room for cleaning this code up.

1/ One would think that when unmounting, we should try
  /proc/mounts first. Only then in /etc/mtab if it wasn't found.
2/ We should look at the name we are passed - if it starts with a '/',
   then assume it is a path name, if it doesn't and it contains a ':',
   we assume a remote address.  Otherwise we reject.
3/ Then the three actions:  tell server, tell kernel, tell mtab
   should be done independently (if appropriate information is
   available).

As for your patch, it definitely identifies a problem, but I'm not
sure it is a good fix.
The only real reason for get_mntproto is to look in /proc/mounts, and
you have changed it to not look there.
Also hasmntvalue really isn't needed.  Just use
   hasmntopt(options,"udp") || hasmntopt(options,"proto=udp")


Anyone want to put together a little patch series to fix some/all of
the above issues? :-)

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
