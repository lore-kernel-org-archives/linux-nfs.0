Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:43255 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbbBLPiE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2015 10:38:04 -0500
Date: Thu, 12 Feb 2015 10:38:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nix <nix@esperi.org.uk>
Cc: NeilBrown <neilb@suse.de>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150212153802.GA3156@fieldses.org>
References: <87iofju9ht.fsf@spindle.srvr.nix>
 <20150203195333.GQ22301@fieldses.org>
 <87egq6lqdj.fsf@spindle.srvr.nix>
 <87r3u58df2.fsf@spindle.srvr.nix>
 <20150205112641.60340f71@notabene.brown>
 <87zj8l7j3z.fsf@spindle.srvr.nix>
 <20150210183200.GB11226@fieldses.org>
 <87y4o4ujwh.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87y4o4ujwh.fsf@spindle.srvr.nix>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 11:07:42PM +0000, Nix wrote:
> On 10 Feb 2015, J. Bruce Fields said:
> 
> > On Tue, Feb 10, 2015 at 05:48:48PM +0000, Nix wrote:
> >> On 5 Feb 2015, NeilBrown spake thusly:
> >> 
> >> > On Wed, 04 Feb 2015 23:28:17 +0000 Nix <nix@esperi.org.uk> wrote:
> >> >> It doesn't. It still recurs.
> >> >
> >> > Is /usr/archive still exported to mutilate with crossmnt?
> >> > If it is, can you change to not do that (it is quite possible to have
> >> > different export options for different clients).
> >> 
> >> OK. Adjusted.
> >> 
> >> > I think that if crossmnt is enabled on the server, then explicitly
> >> > mounting /usr/archive/series will have the same net effect as not doing so
> >> > (though I'm not 100% certain).
> >> >
> >> > Also, can you try changing
> >> >    /proc/sys/fs/nfs/nfs_mountpoint_timeout
> >> >
> >> > It defaults to 500 (seconds - time for light from Sun to reach Earth).
> >> > If you make it smaller and the problem gets worse, or make it much bigger
> >> > and the problem goes away, that would be interesting.
> >> > If it makes no difference, that also would be interesting.
> >> 
> >> Seems to make no difference, which is distinctly surprising. If
> >> anything, it happens more often at the default value than at either the
> >> high or low values. It's very erratic: it happened ten times in one day,
> >> then three days passed and it didn't happen at all... system under
> >> very similar load the whole time.
> >> 
> >> >From other prompts, what I'm seeing now -- but wasn't then, before I
> >> took the crossmnt out -- is an epidemic of spontaneous unmounting: i.e.,
> >> /usr/archive/series suddenly vanishes until remounted.
> >> 
> >> I might just reboot all systems involved in this mess and hope it goes
> >> away. I have no *clue* what's going on, I've never seen it before, maybe
> >> it'll stop if I no longer believe in it.
> >
> > It might be interesting to see output from
> >
> > 	rpc.debug -m rpc -s cache
> > 	cat /proc/net/rpc/nfsd.export/content
> > 	cat /proc/net/rpc/nfsd.fh/content
> >
> > especially after the problem manifests.
> 
> It's manifested right now, as a matter of fact.

Thanks.  Unfortunately nothing there really shouts wrong to me there.

--b.

> 
> # cat /proc/net/rpc/nfsd.export/content
> #path domain(flags)
> /usr/src        mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=16,uuid=333950aa:8e3f440a:bc94d0cc:4adae198,sec=1)
> /usr/share/texlive      mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,fsid=7,uuid=5cccc224:a92440ee:b4450447:3898c2ec,sec=1)
> /home/.spindle.srvr.nix mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=1,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef,sec=1)
> /usr/archive/series     *.srvr.nix,xios.srvr.nix(ro,insecure,root_squash,async,wdelay,no_subtree_check,fsid=29,uuid=543a1ca9:d17246ca:b6c53092:5896549d,sec=1)
> /usr/lib/X11/fonts      mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=12,uuid=5cccc224:a92440ee:b4450447:3898c2ec,sec=1)
> /home/.spindle.srvr.nix *.srvr.nix,fold.srvr.nix(rw,root_squash,async,wdelay,no_subtree_check,fsid=1,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef,sec=1)
> /usr/archive    mutilate.wkstn.nix(rw,insecure,root_squash,async,wdelay,fsid=25,uuid=d20e3edd:06a54a9b:85dcfa19:62975969,sec=1)
> 
> # note: no /usr/archive/series, though I mounted it on mutilate and did
> # not unmount it: however, it no longer appears in /proc/mounts on
> # mutilate and appears as an empty directory under /usr/archive.
> # However, it *does* appear here:
> 
> # cat /proc/net/rpc/nfsd.fh/content
> #domain fsidtype fsid [path]
> *.srvr.nix,xios.srvr.nix 1 0x0000001d /usr/archive/series
> mutilate.wkstn.nix 1 0x0000000f /etc/shai-hulud
> mutilate.wkstn.nix 1 0x0000000b /pkg/non-free
> mutilate.wkstn.nix 1 0x00000016 /usr/share/emacs/site-lisp
> mutilate.wkstn.nix 1 0x00000012 /usr/share/httpd/htdocs/munin
> mutilate.wkstn.nix 1 0x00000013 /usr/share/clamav
> mutilate.wkstn.nix 1 0x0000000a /usr/share/nethack
> mutilate.wkstn.nix 1 0x00000009 /usr/share/xplanet
> mutilate.wkstn.nix 1 0x00000008 /usr/share/xemacs
> mutilate.wkstn.nix 1 0x00000015 /usr/share/flightgear
> mutilate.wkstn.nix 1 0x00000005 /usr/doc
> mutilate.wkstn.nix 1 0x00000006 /usr/info
> mutilate.wkstn.nix 1 0x00000011 /var/state/munin
> mutilate.wkstn.nix 1 0x0000000e /var/log.real
> mutilate.wkstn.nix 1 0x00000007 /usr/share/texlive
> mutilate.wkstn.nix 1 0x00000010 /usr/src
> mutilate.wkstn.nix 1 0x0000000c /usr/lib/X11/fonts
> mutilate.wkstn.nix 1 0x00000019 /usr/archive
> mutilate.wkstn.nix 1 0x0000001d /usr/archive/series
> mutilate.wkstn.nix 1 0x00000001 /home/.spindle.srvr.nix
> *.srvr.nix,fold.srvr.nix 1 0x00000001 /home/.spindle.srvr.nix
> 
> When this happens, I get an (unreachable) and broken symlink under /proc
> (not really surprising as the mountpoint has gone) -- but in this
> situation, cd'ing out and back in does not fix it, only a remount does.
> I'm not surprised by *those* symptoms at all.
> 
> > Also, /usr/archive/series is a separate filesystem from /usr/archive,
> > right?  (The output of "mount" run on the server might also be useful.)
> 
> They are separate server filesystems:
> 
> /dev/mapper/main-archive /usr/archive ext4 rw,nosuid,nodev,relatime,nobarrier,commit=30,data=ordered 0 0
> /dev/sdc1 /usr/archive/series ext4 rw,nosuid,nodev,relatime,commit=30,data=ordered 0 0
> /dev/mapper/main-winbackup /usr/archive/winbackup ext4 rw,nosuid,nodev,relatime,nobarrier,commit=30,data=ordered 0 0
> 
> > The reason crossmnt is considered "bad and evil" is that nfsv2 and v3
> > clients don't necessarily expect mountpoints within exports, and may be
> > get confused when (for example), they discover to files with the same
> > inode number that appear to be on the same filesystem.
> 
> That I expected. NFS mounts within NFS mounts are presumably fine (I
> hope so, I've been using them extensively for decades).
> 
> > I'm  not actually sure what the current linux client does--I think it
> > may be smart enough to use the fsid to avoid at least some of those
> > problems.  But NFSv4 clients are the only ones that should really be
> > counted on to get this right.
> 
> I wish I could get NFSv4 to work. It's just screamed about a lack of
> adequate authentication every time I've tried it, and my network is so
> NFS-dependent that significant experimentation is difficult (getting
> anything wrong tends to cause my entire desktop to deadlock in seconds).
> I suppose I should set up some VMs and play in there :)
> 
> -- 
> NULL && (void)
