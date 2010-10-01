Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52437 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756178Ab0JAWAe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 18:00:34 -0400
Date: Fri, 1 Oct 2010 18:00:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nix <nix@esperi.org.uk>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: persistent, quasi-random -ESTALE at mount time
Message-ID: <20101001220018.GE1472@fieldses.org>
References: <87mxra6duq.fsf@spindle.srvr.nix>
 <20100922155235.GE15560@fieldses.org>
 <8762xwqijb.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8762xwqijb.fsf@spindle.srvr.nix>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 23, 2010 at 10:03:36PM +0100, Nix wrote:
> On 22 Sep 2010, J. Bruce Fields verbalised:
> 
> > On Tue, Sep 21, 2010 at 09:28:13PM +0100, Nix wrote:
> >> Sep 21 20:51:39 spindle info: auth_unix_ip: inbuf 'nfsd 192.168.16.20'
> >> Sep 21 20:51:39 spindle info: auth_unix_ip: client 0x1f3dde0 'mutilate.wkstn.nix'
> >> Sep 21 20:51:39 spindle info: nfsd_fh: inbuf 'mutilate.wkstn.nix 7 \x014000000000000095bd22c2253c456f8e36b6cfb9ecd4ef'
> >
> > 7 is FSID_UUID16_INUM.
> >
> >> Sep 21 20:51:39 spindle info: nfsd_fh: found (nil) path (null)
> >
> > And mountd didn't find any filesystem matching the given uuid.  That's
> > strange.
> 
> I'll say.

Sorry for the slow response; have you figured out anything more?

Looking through your data quickly:

...
> Now I rebooted the server, leaving the client running (actually two are
> connected right now: 'fold' is my firewall. I think you can probably
> ignore it.) Post-reboot, it looked like this:
> 
> ,----
> | #uid cnt: gids...
> | # expiry=1285274048 refcnt=1 flags=3
> | # 1000 0:
> | #class IP domain
> | # expiry=1285275728 refcnt=2 flags=1
> | nfsd 192.168.16.20 mutilate.wkstn.nix
> | #path domain(flags)
> | #domain fsidtype fsid [path]
> | # expiry=2147483647 refcnt=1 flags=3
> | # mutilate.wkstn.nix 7 0x0000400100000000c222bd956f453c25cfb6368eefd4ecb9
> `----
> 
> I flipped RPC debug on and rebooted the client next. The server said:
> 
> Sep 23 21:33:15 spindle warning: [  127.385537] RPC:       Want update, refage=120, age=0
> Sep 23 21:33:15 spindle warning: [  127.536779] RPC:       Want update, refage=120, age=0
> [repeated 40 times]
> 
> When it connected, the server said
> 
> Sep 23 21:34:23 spindle warning: [  195.696257] RPC:       Want update, refage=120, age=68
...
> Sep 23 21:34:38 spindle warning: [  210.766205] RPC:       Want update, refage=120, age=83
> 
> Now, the rpc/*/content files had grown again, and even the -ESTALEd
> filesystems, like /home/.spindle.srvr.nix, are represented once more:

I'm a little confused.  Are you saying that in this case the client did
get ESTALE's?

> I restarted rpc.mountd and the client, so it mounted correctly. Here's a

And then here the problems was cleared and you didn't see any more of
them?

--b.
