Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E31ACC04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 19:53:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AD93B2082B
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 19:53:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD93B2082B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725859AbeLDTxD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 14:53:03 -0500
Received: from fieldses.org ([173.255.197.46]:49126 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725855AbeLDTxD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Dec 2018 14:53:03 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 341811C20; Tue,  4 Dec 2018 14:53:02 -0500 (EST)
Date:   Tue, 4 Dec 2018 14:53:02 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Byron Stanoszek <gandalf@winds.org>
Cc:     Andreas Gruenbacher <agruenba@redhat.com>, jlayton@kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS v4.2 umask getting dropped
Message-ID: <20181204195302.GB3903@fieldses.org>
References: <alpine.LNX.2.21.1.1811241957260.23228@winds.org>
 <20181126140730.GC27372@fieldses.org>
 <CAHc6FU4jup+MxRky2pmVm89L=D42E2Q35s6G-sUSUL-tmXzX-w@mail.gmail.com>
 <alpine.LNX.2.21.1.1811302156420.6541@winds.org>
 <20181204193912.GA3903@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204193912.GA3903@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 04, 2018 at 02:39:12PM -0500, J. Bruce Fields wrote:
> On Fri, Nov 30, 2018 at 10:13:59PM -0500, Byron Stanoszek wrote:
> > On Mon, 26 Nov 2018, Andreas Gruenbacher wrote:
> > 
> > >On Mon, 26 Nov 2018 at 15:07, J. Bruce Fields <bfields@fieldses.org> wrote:
> > >>
> > >>On Sat, Nov 24, 2018 at 08:18:40PM -0500, Byron Stanoszek wrote:
> > >>>I would like to report a problem with NFS v4.2: the umask seems to be
> > >>>getting dropped when creating files. This works as expected when
> > >>>connecting with a v4.1 client or any version prior.
> > >>
> > >>Watching the network traffic in wireshark might help determine which
> > >>side is at fault.
> > >
> > >Right, a network dump (tcpdump -w) of the incorrect operation(s) would
> > >be great so that we can have a look with wireshark.
> > 
> > Sorry for the delay. I attached the two tcpdump files from the client side. The
> > server is 10.0.0.2 (lnxsvr1) and the client is 10.0.0.13 (burner). In both
> > cases, I ran:
> > 
> > mount lnxsvr1:/test -overs=4.x /ext0
> > touch /ext0/blah
> > umount /ext0
> > 
> > and waited ~3 seconds between each command entry.
> 
> Thanks!
> 
> I looked at nfs4_2.pcap.  You can see the OPEN that creates the file in
> frame 56.  If expand OPEN->Open Type you'll see the only attribute it's
> setting htere is mode_umask, with mode 0666 and umask 022.
> 
> There's a GETATTR later in the compound which queries attributes
> including the mode.  The reply, in frame frame 57, gives 0666 for the
> mode.
> 
> So, that's a server bug: for some reason the server isn't applying the
> umask it was given.
> 
> > >In 4.2 the umask is sent in a separate attribute, in earlier versions the
> > >umask and open mode are combined by the client and only the result is sent.
> > 
> > Does "separate attribute" mean "future packet transmission", or is the
> > file_create+change_mode operation still atomic? I'm concerned that if "root"
> > creates an unexpected mode 666 file via the nfs client for a short period of
> > time, that opens up an avenue for a non-root user on the server side to write
> > things into the file before the nfs server processes the "umask"
> > command/packet.
> 
> So the mode_umask is being sent as part of the OPEN, and knfsd is
> supposed to apply the mode and umask atomically.
> 
> > >What filesystem type is /users/files on on lnxsvr1?
> > 
> > reiserfs, with XATTRs disabled:
> > 
> > CONFIG_REISERFS_FS=y
> > # CONFIG_REISERFS_CHECK is not set
> > # CONFIG_REISERFS_PROC_INFO is not set
> > # CONFIG_REISERFS_FS_XATTR is not set
> 
> OK, seems unlikely to be a reiserfs bug, but that's also something
> that's probably doesn't get a lot of testing.

Hm, OK I'll be honest I'm reluctant to devote a lot of time to debugging
this unusual combination (reiserfs with posix acl support configured
out), but on a quick skim it looks like reiser *might* depend on
reiserfs_inherit_default_acl() to apply the umask, but in your case
that's probably configured to be a dummy function that does nothing.
And in that case the vfs should take responsibility for applying the
umask, but that depends on SB_POSIXACL being unset on the superblock--I
wonder if that could be set incorrectly?

--b.
