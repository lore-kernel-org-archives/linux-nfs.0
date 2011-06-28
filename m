Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47533 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755958Ab1F1CLz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jun 2011 22:11:55 -0400
Date: Tue, 28 Jun 2011 12:11:44 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] mount: improve signal management when locking mtab.
Message-ID: <20110628121144.0afb228e@notabene.brown>
In-Reply-To: <4E08B7D8.6050405@RedHat.com>
References: <20110622163852.71a2ae80@notabene.brown>
	<B1677B7E-3A7E-418B-9CCA-0844510B59C8@oracle.com>
	<20110623092052.414d78a8@notabene.brown>
	<4D5CF8CE-FDFE-491D-99A4-D35853DDEA61@oracle.com>
	<4E08B7D8.6050405@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 27 Jun 2011 13:03:20 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 06/23/2011 12:09 PM, Chuck Lever wrote:
> > 
> > On Jun 22, 2011, at 5:20 PM, NeilBrown wrote:
> > 
> >> On Wed, 22 Jun 2011 09:08:25 -0600 Chuck Lever <chuck.lever@oracle.com> wrote:
> >>
> >>> Since we are going to adopt libmount for mount.nfs in the near future, would it be better to update libmount instead?
> >>
> >> How near?
> >>
> >> Libmount appears to get signal handling right already (though I haven't
> >> tested it).  It blocks all signals rather than catching some of them.
> >>
> >> So switching to libmount would a perfectly reasonably response.  However if
> >> that is more than a few weeks away I think I would rather see this fixed up
> >> anyway...
> > 
> > We have a libmount-based mount.nfs already in the nfs-utils tree, IIRC.  I don't think we yet have a generic plan for switching to installing that one by default.  Steve?
> Well a while back I did add the libmount code along with --enable-libmount-mount 
> configure flag. This flag has been enabled for a while now in the 
> pre release of Fedora 16 so it will on in the release of f16. 
> 
> Plus I am looking to make a nfs-utils release... I'm in the process of
> clean things up just to do that. So I would be willing to enable the libmount
> code to be on by default. But I am concern not all distros do include
> the libmount code... 
> 
> Some clarity... If the libmount code is enabled, this patch is not needed?
> 

No it is not ... however it would be nice if the affected code wasn't even
compiled in.

i.e. which a patch like this, it will not even compile the offending code if
libmount is selected.

NeilBrown


diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 056293c..7bc3e2b 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -9,11 +9,10 @@ man5_MANS	= nfs.man
 
 sbin_PROGRAMS	= mount.nfs
 EXTRA_DIST = nfsmount.x $(man8_MANS) $(man5_MANS)
-mount_common = error.c network.c fstab.c token.c \
+mount_common = error.c network.c token.c \
 		    parse_opt.c parse_dev.c \
 		    nfsmount.c nfs4mount.c stropts.c\
-		    nfsumount.c \
-		    mount_constants.h error.h network.h fstab.h token.h \
+		    mount_constants.h error.h network.h token.h \
 		    parse_opt.h parse_dev.h \
 		    nfs4_mount.h nfs_mount4.h stropts.h version.h \
 		    mount_config.h utils.c utils.h
@@ -33,7 +32,8 @@ if CONFIG_LIBMOUNT
 mount_nfs_SOURCES += mount_libmount.c
 mount_nfs_LDADD += $(LIBMOUNT)
 else
-mount_nfs_SOURCES += mount.c
+mount_nfs_SOURCES += mount.c fstab.c nfsumount.c fstab.h
+
 endif
 
 MAINTAINERCLEANFILES = Makefile.in
