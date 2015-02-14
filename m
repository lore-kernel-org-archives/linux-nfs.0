Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:48990 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024AbbBNNRH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Feb 2015 08:17:07 -0500
From: Nix <nix@esperi.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.de>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix> <87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
Date: Sat, 14 Feb 2015 13:17:00 +0000
In-Reply-To: <20150210183200.GB11226@fieldses.org> (J. Bruce Fields's message
	of "Tue, 10 Feb 2015 13:32:00 -0500")
Message-ID: <87vbj4ljjn.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10 Feb 2015, J. Bruce Fields outgrape:

> It might be interesting to see output from
>
> 	rpc.debug -m rpc -s cache
> 	cat /proc/net/rpc/nfsd.export/content
> 	cat /proc/net/rpc/nfsd.fh/content
>
> especially after the problem manifests.

So the mount has vanished again. I couldn't make it happen with
nordirplus in the mount options, so that might provide you with a clue.

Obviously, on the client, no useful output was seen (I learned to avoid
NFS cross-exports long ago, so the client doesn't normally NFS-export
anything).

On the server:

# cat /proc/net/rpc/nfsd.export/content
#path domain(flags)
# expiry=1423920264 refcnt=1 flags=1
/usr/src        mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=16,uuid=333950aa:8e3f440a:bc94d0cc:4adae198,sec=1)
# expiry=1423920746 refcnt=1 flags=1
/home/.spindle.srvr.nix mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,fsid=1,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef,sec=1)
# expiry=1423920907 refcnt=1 flags=1
/usr/lib/X11/fonts      mutilate.wkstn.nix(ro,root_squash,async,wdelay,fsid=12,uuid=5cccc224:a92440ee:b4450447:3898c2ec,sec=1)
# expiry=1423920721 refcnt=1 flags=1
/home/.spindle.srvr.nix *.srvr.nix,fold.srvr.nix(rw,root_squash,async,wdelay,no_subtree_check,fsid=1,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef,sec=1)

# cat /proc/net/rpc/nfsd.fh/content
#domain fsidtype fsid [path]
# expiry=2147483647 refcnt=1 flags=1
*.vm.nix,192.168.20.0/24,owork.vm.nix 1 0x00000010 /usr/src
# expiry=2147483647 refcnt=1 flags=1
*.vm.nix,192.168.20.0/24,owork.vm.nix 1 0x00000016 /home/oranix/o
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000018 /home/.spindle.srvr.nix/nix/Graphics/Private
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000003 /home/.spindle.srvr.nix/nix/Graphics/Photos
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000002 /home/.spindle.srvr.nix/nix/Mail/nnmh/spambox-verified
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000013 /usr/share/clamav
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000012 /usr/share/httpd/htdocs/munin
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000011 /var/state/munin
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x0000001d /usr/archive/series
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000010 /usr/src
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x0000000b /pkg/non-free
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000015 /usr/share/flightgear
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000007 /usr/share/texlive
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x0000000a /usr/share/nethack
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000009 /usr/share/xplanet
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000016 /usr/share/emacs/site-lisp
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000008 /usr/share/xemacs
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000005 /usr/doc
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000006 /usr/info
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x0000000f /etc/shai-hulud
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x0000000e /var/log.real
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x0000000c /usr/lib/X11/fonts
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000019 /usr/archive
# expiry=2147483647 refcnt=1 flags=1
mutilate.wkstn.nix 1 0x00000001 /home/.spindle.srvr.nix
# expiry=2147483647 refcnt=1 flags=1
*.vm.nix,192.168.20.0/24,linux-o.vm.nix 1 0x00000010 /usr/src
# expiry=2147483647 refcnt=1 flags=1
*.vm.nix,192.168.20.0/24,linux-o.vm.nix 1 0x00000016 /home/oranix/o
# expiry=2147483647 refcnt=1 flags=1
*.srvr.nix,fold.srvr.nix 1 0x00000001 /home/.spindle.srvr.nix

I remounted it, and nfsd.export/content gained a few lines:

# expiry=1423921406 refcnt=1 flags=1
/usr/archive/series     mutilate.wkstn.nix(rw,insecure,root_squash,async,wdelay,no_subtree_check,fsid=29,uuid=543a1ca9:d17246ca:b6c53092:5896549d,sec=1)
# expiry=1423921383 refcnt=1 flags=1
/usr/archive    mutilate.wkstn.nix(rw,insecure,root_squash,async,wdelay,fsid=25,uuid=d20e3edd:06a54a9b:85dcfa19:62975969,sec=1)

nfsd.fh/content is unchanged.

To me, this all looks completely normal: unused mounts *do* expire away.
The problem is that they're not coming back as they should (I guess
they're coming back with a different inode number?)

This is all with nfs-utils 1.3.0, btw.

-- 
NULL && (void)
