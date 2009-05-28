From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.29+ NFS-Server Problem "reconnect_path: npd != pd"
Date: Thu, 28 May 2009 16:28:03 -0400
Message-ID: <20090528202803.GF13860@fieldses.org>
References: <20090521142026.GA5566@geggus.net> <1242924599.6687.1.camel@heimdal.trondhjem.org> <20090521165751.GA4428@geggus.net> <1242927133.6687.4.camel@heimdal.trondhjem.org> <gv4463$6fn$1@ultimate100.geggus.net> <1242929546.22947.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sven Geggus <lists@fuchsschwanzdomain.de>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42922 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758720AbZE1U2H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2009 16:28:07 -0400
In-Reply-To: <1242929546.22947.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 21, 2009 at 02:12:26PM -0400, Trond Myklebust wrote:
> On Thu, 2009-05-21 at 17:48 +0000, Sven Geggus wrote:
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > 
> > > So what is the underlying filesystem that you are exporting, and what
> > > does your /etc/exports file look like?
> > 
> > The underlying filesystem is xfs and /etc/exports (unchanged) is here:
> > 
> > --cut--
> > # /etc/exports: the access control list for filesystems which may be exported
> > #		to NFS clients.  See exports(5).
> > /               192.168.3.2(rw,no_root_squash,async,subtree_check)
> > /home/sven	192.168.3.2(rw,no_root_squash,async,subtree_check) 192.168.3.6(rw,no_root_squash,async,subtree_check) 192.168.3.8(rw,no_root_squash,async,subtree_check)
> > /home/mp3	192.168.3.2(rw,no_root_squash,async,subtree_check) 192.168.3.6(rw,no_root_squash,async,subtree_check) 192.168.3.8(rw,no_root_squash,async,subtree_check)
> > /home/sven/filme 192.168.3.7(ro,async,subtree_check)
> > /home/kathi910	192.168.3.7(rw,no_root_squash,async,no_subtree_check)
> > --cut--
> > 
> > 192.168.3.2 is the client which causes the error, I didn't notice the
> > error on the other clients, but they are not used that often.
> > 
> > Especially 192.168.3.7 does seem to work.
> > 
> > Regards
> > 
> > Sven
> > 
> 
> Reforwarding the reply for the benefit of the NFS mailing list. Not
> everyone reads lkml...

Original thread starts here:

	http://marc.info/?l=linux-kernel&m=124291571326139&w=2

I don't think this is a known bug.

Looks like you have subtree_check set on the "bad" export, and
no_subtree_check set on the "good" export.  subtree_check can result in
spurious stale errors when files are renamed, so it's possible this is
by design.

You say you get that message on 296.29.x but not 2.6.27.x.  And you say
you also get stale filehandle errors.  I assume you didn't get the same
stale filehandle errors on 2.6.27.x?

--b.
