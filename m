Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47266 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755153AbdDMS21 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Apr 2017 14:28:27 -0400
Date: Thu, 13 Apr 2017 14:28:27 -0400
To: Leonhard Preis <leonhard.preis@radarservices.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: mountd v4root ignores anonuid and anongid for pseudo file system
Message-ID: <20170413182827.GB5140@fieldses.org>
References: <4218b9fa-e215-370a-f913-348e055d33e2@radarservices.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4218b9fa-e215-370a-f913-348e055d33e2@radarservices.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 20, 2017 at 01:17:40PM +0100, Leonhard Preis wrote:
> Recently I have been investigating[1] why Vagrant’s automatically
> created NFS shares fail to mount when using NFSv4 on Ubuntu 16.04 while
> they work fine on Debian Stretch. In the end the cause really is
> trivial: Debian created my home directory with 0755 while Ubuntu went
> with 0700. The pseudo file system created by mountd seems to mirror
> these permissions while ignoring that Vagrant set
> `all_squash,anonuid=1000,anongid=1000`. Thus the client trying to mount
> the exported directory is denied access. In my opinion this is a bug
> since uid and gid 1000 would have access to the home directory. But I do
> see that a second NFS share without the exact same options would create
> a dilemma. At the very least a log message indicating this situation
> would be very helpful. Nevertheless I’m not too familiar with NFS and
> would appreciate your take on this.

Access denied due to inadequate permissions is much too common for us to
log by default.

> While the solution is simple my lack of knowledge had me dive deep into
> the web to understand what was going wrong. My biggest obstacle was
> definitely the documentation. While the automatically created pseudo
> file system was introduced back in 2010[8][9] it is hardly documented[5]
> . The closest one can get to understand to what’s happening without
> diving into the source code and the accompanying git log itself is a
> very outdated discussion from before it was implemented and a note
> saying that “all of this has since been mostly fixed”[6]. Meanwhile
> almost every tutorial on NFSv4 I remember reading last week still claims
> you need to set up a pseudo root. While some may not claim it there is
> not a single one explaining what is happening if you don’t including the
> man page[3][4][12]:

Patches definitely welcome, this is a common source of confusion.

> Especially confusing is the following statement from mountd’s man page[4]:
> 
> > The rpc.mountd daemon implements the server side of the NFS MOUNT
> protocol, an NFS side protocol used by NFS version 2 [RFC1094] and NFS
> version 3 [RFC1813].

Yes, an extra sentence or two would be useful.  I'm not sure exactly
what, maybe something like:

	It is also responsible for helping the kernel map path names and
	filehandles to exports, for all NFS versions.

> For me this sounds almost like NFSv4 does not use mountd. Apparently
> even Novell thinks that[11]:
> 
> > rpc.mountd — […] This is not used with NFSv4.
> 
> Last but not least it’s not exactly helping that mountd does not log its
> debug stuff to journald, only daemon.log (Debian) or syslog (Ubuntu). I
> admit to failing to find these logs until the end when I grep’d for
> “v4root” in the log directories. But I have seen that there’s something
> happening in regards to systemd with version 2 of nfs-utils so that
> point may be moot.

Huh.  I was watching logs with "journalctl -f" just yesterday and seeing
some mountd messages.  I'm not sure what's up there.

> Oh, and one more thing: mountd hiding the pseudo exports to showmount[2]
> and exportfs without an option to show them anyway is yet another hint
> denied.

We wouldn't want them visible over the MOUNT protocol (what showmount
uses), but I agree that an exportfs option might be useful.  For
debugging purposes it can also be useful to cat
/proc/net/rpc/nfsd.{export,fh}/content, which might be worth
documenting.

--b.

> My personal highlight is the, usually top-notch, Arch Wiki[7]
> which has a (disputed) claim[7] that NFS requires shares to reside below
> /srv. I hope to find some time this week to improve their documentation.
> 
> While I may have had a lot of fun with the documentation, I have no
> complaints about the rock-solid software itself and want to use this
> opportunity to thank the developers for all their efforts!
> 
> As I wrote before I kindly ask for your opinion on the matter and what I
> may have missed. Thank you!
> 
> Cheers,
> 
> Leonhard
> 
> [1] https://github.com/mitchellh/vagrant/issues/8279
> 
> [2]
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=patch;h=de108c531e29ba936a68a6efb99095ad6d6cec8f
> 
> [3]
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=blob;f=utils/exportfs/exports.man;h=d8de6bec2583144bace5a7352d5db58e0882e60d;hb=HEAD
> 
> 
> [4]
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=blob;f=utils/mountd/mountd.man;h=9978afcdb4ccb3ef59e5007fa93a1519062cb45c;hb=HEAD
> 
> [5] http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration
> 
> [6] http://wiki.linux-nfs.org/wiki/index.php/Pseudofilesystem_improvements
> 
> [7]
> https://wiki.archlinux.org/index.php/NFS/Troubleshooting#mount.nfs4:_access_denied_by_server_while_mounting
> 
> [8]
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=patch;h=b25694320f2bdd79de82f2003209b8229eafff36
> 
> [9]
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=patch;h=3b777b084a438f55482c8bf7508903ff4c30e1db
> 
> [10]
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=patch;h=de108c531e29ba936a68a6efb99095ad6d6cec8f
> 
> [11] https://www.novell.com/coolsolutions/feature/17581.html
> 
> [12]
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=blob;f=utils/exportfs/exportfs.man;h=91d3589e38d62cb72a343b13b10f0052aec1cbfd;hb=HEAD
> 
> 



