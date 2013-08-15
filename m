Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756577Ab3HOOBx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Aug 2013 10:01:53 -0400
Date: Thu, 15 Aug 2013 10:02:44 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jan Stancek <jstancek@redhat.com>, linux-nfs@vger.kernel.org,
        bfields@redhat.com, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: fix NFSv3 with sec=krb5 and CONFIG_NFS_V3_ACL=y
Message-ID: <20130815100244.370de645@corrin.poochiereds.net>
In-Reply-To: <20130726220924.GG30651@fieldses.org>
References: <682ebd8ecc7309b18396da356a0feb38bfa41674.1372692346.git.jstancek@redhat.com>
	<20130708201643.GI29071@fieldses.org>
	<1157529877.873319.1373353194344.JavaMail.root@redhat.com>
	<20130726220924.GG30651@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 26 Jul 2013 18:09:24 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jul 09, 2013 at 02:59:54AM -0400, Jan Stancek wrote:
> > 
> > 
> > 
> > 
> > ----- Original Message -----
> > > From: "J. Bruce Fields" <bfields@fieldses.org>
> > > To: "Jan Stancek" <jstancek@redhat.com>
> > > Cc: linux-nfs@vger.kernel.org, bfields@redhat.com, "Trond Myklebust" <Trond.Myklebust@netapp.com>
> > > Sent: Monday, 8 July, 2013 10:16:43 PM
> > > Subject: Re: [PATCH] NFS: fix NFSv3 with sec=krb5 and CONFIG_NFS_V3_ACL=y
> > > 
> > > On Mon, Jul 01, 2013 at 05:32:34PM +0200, Jan Stancek wrote:
> > > > Starting with commit:
> > > >   commit f994c43d19a9116727d4c228d3f13db595bff562
> > > >   Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > >   Date:   Thu Nov 1 12:14:14 2012 -0400
> > > >       SUNRPC: Clean up rpc_bind_new_program
> > > > 
> > > > operations on directory mounted with -onfsvers=3,tcp,sec=krb5 fail
> > > > with Input/Output error after ~60 second timeout. This is presumably
> > > > because upcalls for 'nfsacl' are not getting anywhere.
> > > > 
> > > > This patch enables pipe dir for nfsacl_program and changes its name
> > > > to 'nfs'. This name will be used in upcalls and whole setup should
> > > > work as it did in past - just with nfs/hostname principal.
> > > 
> > > I think this was the problem that nfs-utils commits
> > > 
> > > 	a1f8afc560 gssd: Remove insane sanity checks of the service name
> > > 	a56989b665 gssd: Handle the target name correctly
> > > 
> > > were supposed to fix?
> > > 
> > > But perhaps the kernel needs a fix too to fix a regression with old
> > > userspace.
> > 
> > I saw this error with nfs-utils.1.2.9-rc1, which should already contain
> > those 2 commits.
> 
> Actually, I think your patch is just a subset of Trond's
> http://mid.gmane.org/<4FA345DA4F4AE44899BD2B03EEEC2FA9092EC392@SACEXCMBX04-PRD.hq.netapp.com>
> 
> Trond, is there a reason that never got applied?
> 
> --b.
> 

Hmm...gmane just says "No such article" when I feed it the above URL.
Do you know what the title of the email was?

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
