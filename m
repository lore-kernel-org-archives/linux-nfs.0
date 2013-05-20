Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56865 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758300Ab3ETVOx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2013 17:14:53 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Eric Paris <eparis@parisplace.org>
CC: Steve Dickson <SteveD@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        "Linux FS devel list" <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/13] Kconfig: Add Kconfig entry for Labeled NFS V4
 client
Date: Mon, 20 May 2013 21:14:51 +0000
Message-ID: <1369084490.52168.5.camel@leira.trondhjem.org>
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
	 <1368719808-14584-14-git-send-email-SteveD@redhat.com>
	 <CACLa4pta+uRLDgU=hriQLVseJvtA-FJDCRK-oYKmzVNiRs299Q@mail.gmail.com>
	 <1369084374.52168.3.camel@leira.trondhjem.org>
In-Reply-To: <1369084374.52168.3.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-05-20 at 17:12 -0400, Trond Myklebust wrote:
> On Mon, 2013-05-20 at 16:57 -0400, Eric Paris wrote:
> > On Thu, May 16, 2013 at 11:56 AM, Steve Dickson <SteveD@redhat.com> wrote:
> > > From: Steve Dickson <steved@redhat.com>
> > >
> > > This patch adds the NFS_V4_SECURITY_LABEL entry which
> > > enables security label support for the NFSv4 client
> > >
> > > Signed-off-by: Steve Dickson <steved@redhat.com>
> > > ---
> > >  fs/nfs/Kconfig | 19 +++++++++++++++++++
> > >  1 file changed, 19 insertions(+)
> > >
> > > diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> > > index 79c500e..771831d3 100644
> > > --- a/fs/nfs/Kconfig
> > > +++ b/fs/nfs/Kconfig
> > > @@ -107,6 +107,7 @@ config NFS_V4_1
> > >  config NFS_V4_2
> > >         bool "NFS client support for NFSv4.2"
> > >         depends on NFS_V4_1
> > > +       select NFS_V4_SECURITY_LABEL
> > 
> > So this will force it on...
> > 
> > >         help
> > >           This option enables support for minor version 1 of the NFSv4 protocol
> > >           in the kernel's NFS client.
> > > @@ -140,6 +141,24 @@ config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
> > >           If the NFS client is unchanged from the upstream kernel, this
> > >           option should be set to the default "kernel.org".
> > >
> > > +config NFS_V4_SECURITY_LABEL
> > > +       bool "Provide Security Label support for NFSv4 client"
> > > +       depends on NFS_V4 && SECURITY
> > 
> > Even if SECURITY is not set?
> > 
> > Why are you forcing this on with a select?  select is dangerous..
> 
> Eric is right. In any case, we already agreed that we don't need _both_
> a NFSv4.2 and a NFSv4 security label switch.
> 
> Please just get rid of NFS_V4_SECURITY_LABEL.
> 

Sorry. I mean, just replace it with

config NFS_V4_SECURITY_LABEL
	bool
	depend on NFS_V4_2 && SECURITY
	default Y


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
