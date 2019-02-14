Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E960C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 21:06:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3F4DE2089F
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 21:06:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392702AbfBNVGw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 16:06:52 -0500
Received: from fieldses.org ([173.255.197.46]:37742 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387417AbfBNVGw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Feb 2019 16:06:52 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 22B421E2B; Thu, 14 Feb 2019 16:06:52 -0500 (EST)
Date:   Thu, 14 Feb 2019 16:06:52 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Jeremy Allison <jra@samba.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, Jeff Layton <jlayton@kernel.org>,
        samba-technical@lists.samba.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
Message-ID: <20190214210652.GC9216@fieldses.org>
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org>
 <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
 <20190208221239.GA199180@jra3>
 <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Feb 09, 2019 at 06:04:22AM +0200, Amir Goldstein wrote:
> On Sat, Feb 9, 2019 at 12:12 AM Jeremy Allison <jra@samba.org> wrote:
> >
> > On Fri, Feb 08, 2019 at 10:02:43PM +0200, Amir Goldstein via samba-technical wrote:
> > > On Fri, Feb 8, 2019 at 5:51 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > > >
> > > > On Fri, Feb 08, 2019 at 04:45:46PM +0200, Amir Goldstein wrote:
> > > > > - check_conflicting_open() is changed to use inode_is_open_for_read()
> > > > >   instead of checking d_count and i_count.
> > > >
> > > > Independently of the rest, I'd love to do away with those
> > > > d_count/i_count checks.  What's inode_is_open_for_read()?
> > > >
> > >
> > > It would look maybe something like this:
> > >
> > > static inline bool file_is_open_for_read(const struct inode *file)
> > > {
> > >         struct inode *inode = file_inode(file);
> > >         int countself = (file->f_mode & (FMODE_READ | FMODE_WRITE)) ==
> > > FMODE_READ) ? 1 : 0;
> > >
> > >         return atomic_read(&inode->i_readcount) > countself;
> > > }
> > >
> > > And it would allow for acquiring F_WRLCK lease if other
> > > instances of inode are open O_PATH.
> > > A slight change of semantics that seems harmless(?)
> > > and will allow some flexibility.
> > >
> > > But if samba can't figure out a way to keep a single open file
> > > descriptor for oplocks per client-file, then this model doesn't
> > > help us make any progress.
> >
> > Samba uses a single file descriptor per SMB2 open file
> > handle. Is this what you meant ? We need this to keep
> > the per-handle OFD locks around.
> 
> I understand now there are several cases when smbd has
> several open file descriptors for the same client.
> Is that related to this comment in samba wiki about kernel oplocks?
> 
> "Linux kernel oplocks don't provide the needed features.
> (They don't even work correctly for oplocks...)"
> 
> Can you elaborate on that? is that because a samba oplock
> is per client and therefore other file opens from same client
> should not break its own lease?
> If that is the case, than Bruce's work on the "delegations"
> flavor of kernel oplocks could make them a good fit for samba.

After this:

	https://marc.info/?l=linux-nfs&m=154966239918297&w=2

delegations would no longer conflict with opens from the same tgid.  So
if your threads all run in the same process and you're willing to manage
conflicts among your own clients, that should still allow you to do
multiple opens of the same file without giving up your lease/delegation.

I'd be curious to know whether that works with Samba's design.

--b.
