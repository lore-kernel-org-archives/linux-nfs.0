From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS/IPv6
Date: Tue, 04 Aug 2009 13:49:17 -0400
Message-ID: <1249408157.5041.6.camel@heimdal.trondhjem.org>
References: <1249407324.5041.4.camel@heimdal.trondhjem.org>
	 <57B0749C-FFCC-4D8C-9417-DF18C0A3CD48@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Dr. J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27785 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932828AbZHDRth (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 13:49:37 -0400
In-Reply-To: <57B0749C-FFCC-4D8C-9417-DF18C0A3CD48@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-04 at 13:37 -0400, Chuck Lever wrote:
> On Aug 4, 2009, at 1:35 PM, Trond Myklebust wrote:
> > Hi guys,
> >
> > There was apparently a presentation and proposal made at the IETF in
> > Stockholm w.r.t. standardising IPv6 support in lockd/statd, and adding
> > link-local addresses to NFSv4. The proposal could possibly have
> > consequences for our implementation efforts.
> >
> > Please see the slides and minutes here
> >
> > http://www.ietf.org/proceedings/75/minutes/nfsv4.txt
> >
> >  and
> >
> > http://www.ietf.org/proceedings/75/slides/nfsv4-0.pdf
> 
> Was Mike Eisler involved?  I recently reviewed a draft RFC on this  
> topic.

Mike didn't present it, but the person who did was indeed from NetApp,
so it is possible that this is the same RFC...

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
