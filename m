Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33149 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422677Ab2KNQIJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 11:08:09 -0500
Date: Wed, 14 Nov 2012 11:08:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org, Eldad Zack <eldad@fogrefinery.com>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
Message-ID: <20121114160808.GH23604@fieldses.org>
References: <20121109200730.GI6171@fieldses.org>
 <E1TWxKX-00025I-J2@diesel.geggus.net>
 <20121109232410.GK6171@fieldses.org>
 <20121112091717.GA1610@geggus.net>
 <20121113224005.GA11545@fieldses.org>
 <20121114005815.GA23604@fieldses.org>
 <20121114160712.GG23604@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121114160712.GG23604@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 14, 2012 at 11:07:13AM -0500, J. Bruce Fields wrote:
> On Tue, Nov 13, 2012 at 07:58:15PM -0500, J. Bruce Fields wrote:
> > On Tue, Nov 13, 2012 at 05:40:05PM -0500, J. Bruce Fields wrote:
> > > On Mon, Nov 12, 2012 at 10:17:17AM +0100, Sven Geggus wrote:
> > > > J. Bruce Fields schrieb am Samstag, den 10. November um 00:24 Uhr:
> > > > 
> > > > OK, back at work and here is what I get:
> > > > 
> > > > > Restart the server, start strace, then try the mount, let it hang a few
> > > > > seconds just to make sure you got anything interesting, then kill strace
> > > > > and send the output.
> > > > 
> > > > OK, back at work and here is what I get...
> > > > 
> > > > read(3, "nfsd 10.1.7.30\n", 2048)       = 15
> > > > close(15)                               = 0
> > > > open("/var/lib/nfs/etab", O_RDONLY)     = 15
> > > > close(15)                               = 0
> > > > close(15)                               = 0
> > > > write(3, "nfsd 10.1.7.30 1352710828 * \n", 29) = 29
> > > > read(4, "4294967295\n", 2048)           = 11
> > > > close(16)                               = 0
> > > > close(15)                               = 0
> > > > read(15,
> > > > "\2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0",
> > > > 36) = 36
> > > > close(15)                               = 0
> > > > write(4, "4294967295 1352710828 0 \n", 25) = -1 EINVAL (Invalid argument)
> > > 
> > > I suspect that error's coming from
> > > net/sunrpc/svcauth_unix.c:unix_gid_parse().
> > > 
> > > > 4294967295 is UINT_MAX and this place is where it behaves differently on a good
> > > > kernel where the write call will succeed:
> > > > 
> > > > write(4, "4294967295 1352710828 0 \n", 25) = 25
> > > > 
> > > > Sven
> > > > 
> > > > P.S.: Your patched svcauth_gss.c will give me an "access denied by server"
> > > > while mounting instead of the infinite delay:
> > > >  ~/ # mount -t nfs4 -o sec=krb5 testsrv:/storage /mnt/
> > > > mount.nfs4: access denied by server while mounting testsrv:/storage
> > > 
> > > So, looks like the same get_int problem exists in several other places.
> > > Could you try the following instead of the previous patch?  I think I
> > > got them all this time....
> > 
> > Oh, cripes, but this isn't good enough--svcgssd actually passes down -1
> > id's.  Ugh--I'll take a closer look tomorrow.
> 
> Yeah, for backwards compatibility reasons we probably don't want to
> reject either -1 or 4294967295.
> 
> So I'm inclined to revert unless Eldad has a better idea.
> 
> --b.

Oops, sending the right thing this time.--b.

commit 8688bcb10bd006111b1b46c23a27081ea359e140
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Nov 14 10:48:05 2012 -0500

    svcrpc: Revert "sunrpc/cache.h: replace simple_strtoul"
    
    Commit bbf43dc888833ac0539e437dbaeb28bfd4fbab9f "sunrpc/cache.h: replace
    simple_strtoul" introduced new range-checking which could cause get_int
    to fail on unsigned integers to large to be represented as an int.
    
    We could parse them as unsigned instead--but it turns out svcgssd is
    actually passing down "-1" in some cases.  Which is perhaps stupid, but
    there's nothing we can do about it now.
    
    So just revert back to the previous "sloppy" behavior that accepts
    either representation.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index f792794..5dc9ee4 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -217,6 +217,8 @@ extern int qword_get(char **bpp, char *dest, int bufsize);
 static inline int get_int(char **bpp, int *anint)
 {
 	char buf[50];
+	char *ep;
+	int rv;
 	int len = qword_get(bpp, buf, sizeof(buf));
 
 	if (len < 0)
@@ -224,9 +226,11 @@ static inline int get_int(char **bpp, int *anint)
 	if (len == 0)
 		return -ENOENT;
 
-	if (kstrtoint(buf, 0, anint))
+	rv = simple_strtol(buf, &ep, 0);
+	if (*ep)
 		return -EINVAL;
 
+	*anint = rv;
 	return 0;
 }
 
