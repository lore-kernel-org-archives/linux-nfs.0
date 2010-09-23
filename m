Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:58428 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546Ab0IWVDo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 17:03:44 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: persistent, quasi-random -ESTALE at mount time
References: <87mxra6duq.fsf@spindle.srvr.nix>
	<20100922155235.GE15560@fieldses.org>
From: Nix <nix@esperi.org.uk>
Date: Thu, 23 Sep 2010 22:03:36 +0100
In-Reply-To: <20100922155235.GE15560@fieldses.org> (J. Bruce Fields's message of "Wed, 22 Sep 2010 11:52:35 -0400")
Message-ID: <8762xwqijb.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 22 Sep 2010, J. Bruce Fields verbalised:

> On Tue, Sep 21, 2010 at 09:28:13PM +0100, Nix wrote:
>> Sep 21 20:51:39 spindle info: auth_unix_ip: inbuf 'nfsd 192.168.16.20'
>> Sep 21 20:51:39 spindle info: auth_unix_ip: client 0x1f3dde0 'mutilate.wkstn.nix'
>> Sep 21 20:51:39 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x014000000000000095bd22c2253c456f8e36b6cfb9ecd4ef'
>
> 7 is FSID_UUID16_INUM.
>
>> Sep 21 20:51:39 spindle info: nfsd_fh: found (nil) path (null)
>
> And mountd didn't find any filesystem matching the given uuid.  That's
> strange.

I'll say.

(The uuid of this filesystem is 95bd22c2-253c-456f-8e36-b6cfb9ecd4ef,
which looks just right.)

(btw, my libuuid comes from 61ef2474c24c80a5bf0e24ba85a7506fd7651a5c in
the e2fsprogs maint branch; my libblkid is from util-linux-ng commit
2c26d56ff524bdd9b7bbb45d19e47e67bb2b8d30 (2.18-plus-a-tiny-bit).

These work everywhere else, and indeed they seem to work with
nfs-utils... after a restart. (Obviously, by the time rpc.mountd is
running, LVM has long since been started, local filesystems mounted, and
all the uuids needed for said filesystems should damn well be visible.)

>> I'll try a packet capture next (time to use --port, I guess).

Oops. Forgot. Next time. :)

> The output of
>
> 	rpcdebug -m rpc -s cache
> 	more /proc/net/*/content

(assuming you meant /proc/net/rpc/*/content)

> after a failed startup might be interesting too.

Here. The normal case, first:

,----
| #uid cnt: gids...
| # expiry=1285273838 refcnt=1 flags=3
| # 0 0:
| # expiry=1285273838 refcnt=1 flags=3
| # 1000 0:
| #class IP domain
| # expiry=1285274634 refcnt=1 flags=1
| nfsd 192.168.14.1 fold.srvr.nix
| # expiry=1285275315 refcnt=2 flags=1
| nfsd 192.168.16.20 mutilate.wkstn.nix
| # expiry=2147483647 refcnt=1 flags=1
| nfsd 0.0.0.0 -test-client-
| #path domain(flags)
| # expiry=1285275315 refcnt=1 flags=1
| /usr/doc	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275315 refcnt=1 flags=1
| /var/state/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
| # expiry=1285275315 refcnt=1 flags=1
| /usr/share/xplanet	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275315 refcnt=1 flags=1
| /etc/shai-hulud	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=6c0f7fa7:d6c24054:bff33a87:8460bdc7)
| # expiry=1285275315 refcnt=1 flags=1
| /usr/share/clamav	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275315 refcnt=1 flags=1
| /usr/src	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=333950aa:8e3f440a:bc94d0cc:4adae198)
| # expiry=1285275315 refcnt=1 flags=1
| /usr/share/xemacs	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275315 refcnt=1 flags=1
| /home/.spindle.srvr.nix/nix/Graphics/Photos	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=78c50891:aaac452b:8b4fa769:9565a21e)
| # expiry=1285275315 refcnt=1 flags=1
| /home/.spindle.srvr.nix/nix/Mail/nnmh/spambox-verified	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=52d386c2:b6384034:8bd4e199:5e3237bb)
| # expiry=1285274634 refcnt=1 flags=1
| /home/.spindle.srvr.nix	fold.srvr.nix(rw,root_squash,async,wdelay,no_subtree_check,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef)
| # expiry=1285275315 refcnt=1 flags=1
| /var/log.real	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
| # expiry=1285275315 refcnt=1 flags=1
| /usr/lib/X11/fonts	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275315 refcnt=1 flags=1
| /usr/share/texlive	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275315 refcnt=1 flags=1
| /usr/share/httpd/htdocs/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275315 refcnt=1 flags=1
| /usr/info	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275315 refcnt=1 flags=1
| /home/.spindle.srvr.nix	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef)
| # expiry=1285275315 refcnt=1 flags=1
| /pkg/non-free	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=07799ff5:baef4492:875dc737:30d6149e)
| #domain fsidtype fsid [path]
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000e01e00000000a77f0f6c5440c2d6873af3bfc7bd6084 /etc/shai-hulud
| # expiry=2147483647 refcnt=1 flags=1
| fold.srvr.nix 7 0x0000400100000000c222bd956f453c25cfb6368eefd4ecb9 /home/.spindle.srvr.nix
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000c001000000006b6ecbb545439ded3545d6ab19256ef5 /var/log.real
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 6 0xc286d352344038b699e1d48bbb37325e /home/.spindle.srvr.nix/nix/Mail/nnmh/spambox-verified
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x000120010000000024c2cc5cee4024a9470445b4ecc29838 /usr/info
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000c001000000001e1d2b5e18f3665c0000000000000000 /var/log.real
| # expiry=2147483647 refcnt=1 flags=1
| fold.srvr.nix 6 0x9108c5782b45acaa69a74f8b1ea26595 /home/.spindle.srvr.nix/nix/Graphics/Photos
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 6 0xaa5039330a443f8eccd094bc98e1da4a /usr/src
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0001200100000000e889c66391bc82020000000000000000 /usr/info
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000653d0000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/clamav
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000a0010000000024c2cc5cee4024a9470445b4ecc29838 /usr/doc
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 6 0x9108c5782b45acaa69a74f8b1ea26595 /home/.spindle.srvr.nix/nix/Graphics/Photos
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 6 0xf59f79079244efba37c75d879e14d630 /pkg/non-free
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000400100000000c222bd956f453c25cfb6368eefd4ecb9 /home/.spindle.srvr.nix
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000e01e00000000d3fc452052a2fd930000000000000000 /etc/shai-hulud
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0008a002000000006b6ecbb545439ded3545d6ab19256ef5 /var/state/munin
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 6 0x802458c28a39500c0000000000000000 /pkg/non-free
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x000075af0000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/httpd/htdocs/munin
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x00004001000000001b8b940d9cd091800000000000000000 /home/.spindle.srvr.nix
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x000065820000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/xemacs
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x000a51840000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/texlive
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x000065850000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/xplanet
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x00086de80000000024c2cc5cee4024a9470445b4ecc29838 /usr/lib/X11/fonts
`----

Now I rebooted the server, leaving the client running (actually two are
connected right now: 'fold' is my firewall. I think you can probably
ignore it.) Post-reboot, it looked like this:

,----
| #uid cnt: gids...
| # expiry=1285274048 refcnt=1 flags=3
| # 1000 0:
| #class IP domain
| # expiry=1285275728 refcnt=2 flags=1
| nfsd 192.168.16.20 mutilate.wkstn.nix
| #path domain(flags)
| #domain fsidtype fsid [path]
| # expiry=2147483647 refcnt=1 flags=3
| # mutilate.wkstn.nix 7 0x0000400100000000c222bd956f453c25cfb6368eefd4ecb9
`----

I flipped RPC debug on and rebooted the client next. The server said:

Sep 23 21:33:15 spindle warning: [  127.385537] RPC:       Want update, refage=120, age=0
Sep 23 21:33:15 spindle warning: [  127.536779] RPC:       Want update, refage=120, age=0
[repeated 40 times]

When it connected, the server said

Sep 23 21:34:23 spindle warning: [  195.696257] RPC:       Want update, refage=120, age=68
Sep 23 21:34:23 spindle warning: [  195.696605] RPC:       Want update, refage=120, age=68
Sep 23 21:34:23 spindle warning: [  195.711495] RPC:       Want update, refage=120, age=68
Sep 23 21:34:23 spindle warning: [  195.711741] RPC:       Want update, refage=120, age=0
Sep 23 21:34:23 spindle warning: [  195.712224] RPC:       Want update, refage=120, age=68
Sep 23 21:34:23 spindle warning: [  195.712753] RPC:       Want update, refage=120, age=68
Sep 23 21:34:23 spindle warning: [  195.713279] RPC:       Want update, refage=120, age=68
[repeated eleven times, mostly with seven repetitions, sometimes with eight]
Sep 23 21:34:23 spindle warning: [  195.800687] RPC:       Want update, refage=120, age=68
Sep 23 21:34:23 spindle warning: [  195.801247] RPC:       Want update, refage=120, age=68
Sep 23 21:34:23 spindle warning: [  195.801776] RPC:       Want update, refage=120, age=68
Sep 23 21:34:23 spindle warning: [  195.802316] RPC:       Want update, refage=120, age=68
Sep 23 21:34:23 spindle warning: [  195.802834] RPC:       Want update, refage=120, age=68
Sep 23 21:34:24 spindle warning: [  196.701890] RPC:       Want update, refage=120, age=69
Sep 23 21:34:24 spindle warning: [  196.702235] RPC:       Want update, refage=120, age=69
Sep 23 21:34:24 spindle warning: [  196.778129] RPC:       Want update, refage=120, age=69
Sep 23 21:34:24 spindle warning: [  196.778471] RPC:       Want update, refage=120, age=69
Sep 23 21:34:26 spindle warning: [  198.703264] RPC:       Want update, refage=120, age=71
Sep 23 21:34:26 spindle warning: [  198.703606] RPC:       Want update, refage=120, age=71
Sep 23 21:34:26 spindle warning: [  198.778288] RPC:       Want update, refage=120, age=71
Sep 23 21:34:26 spindle warning: [  198.778632] RPC:       Want update, refage=120, age=71
[...]
Sep 23 21:34:30 spindle warning: [  202.701820] RPC:       Want update, refage=120, age=75
Sep 23 21:34:30 spindle warning: [  202.702162] RPC:       Want update, refage=120, age=75
Sep 23 21:34:30 spindle warning: [  202.775312] RPC:       Want update, refage=120, age=75
Sep 23 21:34:30 spindle warning: [  202.775650] RPC:       Want update, refage=120, age=75
Sep 23 21:34:35 spindle warning: [  207.562434] RPC:       Want update, refage=120, age=0
Sep 23 21:34:35 spindle warning: [  207.562784] RPC:       Want update, refage=120, age=0
Sep 23 21:34:35 spindle warning: [  207.563032] RPC:       Want update, refage=120, age=0
[...]
Sep 23 21:34:38 spindle warning: [  210.693953] RPC:       Want update, refage=120, age=83
Sep 23 21:34:38 spindle warning: [  210.694135] RPC:       Want update, refage=120, age=83
Sep 23 21:34:38 spindle warning: [  210.766049] RPC:       Want update, refage=120, age=83
Sep 23 21:34:38 spindle warning: [  210.766205] RPC:       Want update, refage=120, age=83

Now, the rpc/*/content files had grown again, and even the -ESTALEd
filesystems, like /home/.spindle.srvr.nix, are represented once more:

,----
| #uid cnt: gids...
| # expiry=1285274115 refcnt=1 flags=3
| # 0 0:
| # expiry=1285274195 refcnt=1 flags=3
| # 1000 0:
| #class IP domain
| # expiry=1285275875 refcnt=3 flags=1
| nfsd 192.168.14.1 fold.srvr.nix
| # expiry=1285275878 refcnt=2 flags=1
| nfsd 192.168.16.20 mutilate.wkstn.nix
| #path domain(flags)
| # expiry=1285275878 refcnt=1 flags=1
| /pkg/non-free	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=07799ff5:baef4492:875dc737:30d6149e)
| # expiry=1285275863 refcnt=1 flags=1
| /usr/src	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=333950aa:8e3f440a:bc94d0cc:4adae198)
| # expiry=1285275863 refcnt=1 flags=1
| /usr/share/clamav	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275878 refcnt=1 flags=1
| /home/.spindle.srvr.nix	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef)
| # expiry=1285275863 refcnt=1 flags=1
| /var/log.real	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
| # expiry=1285275875 refcnt=1 flags=1
| /home/.spindle.srvr.nix	fold.srvr.nix(rw,root_squash,async,wdelay,no_subtree_check,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef)
| # expiry=1285275863 refcnt=1 flags=1
| /usr/share/texlive	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275863 refcnt=1 flags=1
| /var/state/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
| # expiry=1285275863 refcnt=1 flags=1
| /usr/info	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275863 refcnt=1 flags=1
| /etc/shai-hulud	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=6c0f7fa7:d6c24054:bff33a87:8460bdc7)
| # expiry=1285275863 refcnt=1 flags=1
| /usr/share/xplanet	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275863 refcnt=1 flags=1
| /usr/share/xemacs	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275863 refcnt=1 flags=1
| /usr/doc	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275863 refcnt=1 flags=1
| /usr/lib/X11/fonts	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| # expiry=1285275863 refcnt=1 flags=1
| /usr/share/httpd/htdocs/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
| #domain fsidtype fsid [path]
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000a0010000000024c2cc5cee4024a9470445b4ecc29838 /usr/doc
| # expiry=2147483647 refcnt=1 flags=3
| # mutilate.wkstn.nix 6 0xf59f79079244efba37c75d879e14d630
| # expiry=2147483647 refcnt=1 flags=3
| # mutilate.wkstn.nix 7 0x0000400100000000c222bd956f453c25cfb6368eefd4ecb9
| # expiry=2147483647 refcnt=1 flags=1
| fold.srvr.nix 7 0x0000400100000000c222bd956f453c25cfb6368eefd4ecb9 /home/.spindle.srvr.nix
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000653d0000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/clamav
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000c001000000006b6ecbb545439ded3545d6ab19256ef5 /var/log.real
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x000120010000000024c2cc5cee4024a9470445b4ecc29838 /usr/info
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 6 0xaa5039330a443f8eccd094bc98e1da4a /usr/src
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0000e01e00000000a77f0f6c5440c2d6873af3bfc7bd6084 /etc/shai-hulud
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x000065820000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/xemacs
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x000a51840000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/texlive
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x000065850000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/xplanet
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x00086de80000000024c2cc5cee4024a9470445b4ecc29838 /usr/lib/X11/fonts
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x000075af0000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/httpd/htdocs/munin
| # expiry=2147483647 refcnt=1 flags=1
| mutilate.wkstn.nix 7 0x0008a002000000006b6ecbb545439ded3545d6ab19256ef5 /var/state/munin
`----

I restarted rpc.mountd and the client, so it mounted correctly. Here's a
diff of the rpc/*/content files in this last stage. Some lines differ
only in times, but many are new:

--- rpc-content.post-server-reboot	2010-09-23 21:33:06.957968742 +0100
+++ rpc-content.back-to-normal	2010-09-23 21:37:17.397020536 +0100
@@ -1,10 +1,76 @@
 #uid cnt: gids...
-# expiry=1285274048 refcnt=1 flags=3
+# expiry=1285274237 refcnt=1 flags=3
 # 1000 0:
 #class IP domain
-# expiry=1285275728 refcnt=2 flags=1
+# expiry=1285276012 refcnt=2 flags=1
 nfsd 192.168.16.20 mutilate.wkstn.nix
 #path domain(flags)
+# expiry=1285276012 refcnt=1 flags=1
+/home/.spindle.srvr.nix/nix/Graphics/Photos	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=78c50891:aaac452b:8b4fa769:9565a21e)
+# expiry=1285276012 refcnt=1 flags=1
+/pkg/non-free	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=07799ff5:baef4492:875dc737:30d6149e)
+# expiry=1285276012 refcnt=1 flags=1
+/usr/src	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=333950aa:8e3f440a:bc94d0cc:4adae198)
+# expiry=1285276012 refcnt=1 flags=1
+/usr/share/clamav	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
+# expiry=1285276011 refcnt=1 flags=1
+/home/.spindle.srvr.nix	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=95bd22c2:253c456f:8e36b6cf:b9ecd4ef)
+# expiry=1285276012 refcnt=1 flags=1
+/var/log.real	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
+# expiry=1285276011 refcnt=1 flags=1
+/home/.spindle.srvr.nix/nix/Mail/nnmh/spambox-verified	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,no_subtree_check,uuid=52d386c2:b6384034:8bd4e199:5e3237bb)
+# expiry=1285276012 refcnt=1 flags=1
+/usr/share/texlive	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
+# expiry=1285276012 refcnt=1 flags=1
+/var/state/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=b5cb6e6b:ed9d4345:abd64535:f56e2519)
+# expiry=1285276012 refcnt=1 flags=1
+/usr/info	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
+# expiry=1285276012 refcnt=1 flags=1
+/etc/shai-hulud	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=6c0f7fa7:d6c24054:bff33a87:8460bdc7)
+# expiry=1285276012 refcnt=1 flags=1
+/usr/share/xplanet	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
+# expiry=1285276012 refcnt=1 flags=1
+/usr/share/xemacs	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
+# expiry=1285276012 refcnt=1 flags=1
+/usr/doc	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
+# expiry=1285276012 refcnt=1 flags=1
+/usr/lib/X11/fonts	mutilate.wkstn.nix(ro,root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
+# expiry=1285276012 refcnt=1 flags=1
+/usr/share/httpd/htdocs/munin	mutilate.wkstn.nix(rw,no_root_squash,async,wdelay,uuid=5cccc224:a92440ee:b4450447:3898c2ec)
 #domain fsidtype fsid [path]
-# expiry=2147483647 refcnt=1 flags=3
-# mutilate.wkstn.nix 7 0x0000400100000000c222bd956f453c25cfb6368eefd4ecb9
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 6 0x9108c5782b45acaa69a74f8b1ea26595 /home/.spindle.srvr.nix/nix/Graphics/Photos
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x0000a0010000000024c2cc5cee4024a9470445b4ecc29838 /usr/doc
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 6 0xf59f79079244efba37c75d879e14d630 /pkg/non-free
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x0000400100000000c222bd956f453c25cfb6368eefd4ecb9 /home/.spindle.srvr.nix
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x0000653d0000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/clamav
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x0000c001000000006b6ecbb545439ded3545d6ab19256ef5 /var/log.real
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 6 0xc286d352344038b699e1d48bbb37325e /home/.spindle.srvr.nix/nix/Mail/nnmh/spambox-verified
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x000120010000000024c2cc5cee4024a9470445b4ecc29838 /usr/info
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 6 0xaa5039330a443f8eccd094bc98e1da4a /usr/src
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x0000e01e00000000a77f0f6c5440c2d6873af3bfc7bd6084 /etc/shai-hulud
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x000065820000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/xemacs
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x00004001000000001b8b940d9cd091800000000000000000 /home/.spindle.srvr.nix
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x000a51840000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/texlive
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x000065850000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/xplanet
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x00086de80000000024c2cc5cee4024a9470445b4ecc29838 /usr/lib/X11/fonts
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x000075af0000000024c2cc5cee4024a9470445b4ecc29838 /usr/share/httpd/htdocs/munin
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 7 0x0008a002000000006b6ecbb545439ded3545d6ab19256ef5 /var/state/munin
+# expiry=2147483647 refcnt=1 flags=1
+mutilate.wkstn.nix 6 0x802458c28a39500c0000000000000000 /pkg/non-free
