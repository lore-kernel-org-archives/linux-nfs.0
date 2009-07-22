From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Bug in server's export -- List of security flavors
Date: Tue, 21 Jul 2009 20:09:55 -0400
Message-ID: <20090722000955.GC20694@fieldses.org>
References: <4A5F5C4C.3070308@excfb.com> <20090716185642.GB2495@fieldses.org> <4A5F7EA9.9050309@excfb.com> <20090716194546.GG2495@fieldses.org> <4A5F8A00.8000104@excfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbZGVAJz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2009 20:09:55 -0400
In-Reply-To: <4A5F8A00.8000104-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 16, 2009 at 03:13:52PM -0500, Tom Haynes wrote:
> support/nfs/exports.c
>
> 505                 if (strcmp(opt, "ro") == 0)
> 506                         setflags(NFSEXP_READONLY, active, ep);
> 507                 else if (strcmp(opt, "rw") == 0)
> 508                         clearflags(NFSEXP_READONLY, active, ep);
> ...
> 624                 } else if (strncmp(opt, "sec=", 4) == 0) {
> 625                         active = parse_flavors(opt+4, ep);
>
> If you find a 'sec=' you go ahead and set it in the e_secinfo array.
>
> But if you encounter a rw or ro before you encounter a 'sec=', you do
> not set a flavor in the e_secinfo array.

Yep, thanks!

> What we do is if we encounter the 'rw' or 'ro' before the 'sec=', then
> it defaults to being a AUTH_SYS flavor. If we encounter it after, then
> we know which flavor to set it as.

I think at least in our case it's easier just to check for the no-sec=
case at the time we construct the MOUNT response and put that default
case there.  Patch follows.

>
> Of course, we have to account for what happens if we have the following:
> share -F nfs -o rw,sec=sys,ro /foo
>
> Because we can't have both a rw and ro export.

I believe the current linux nfs-utils code allows conflicting export
options, and lets the last option specified win.

Also, if the first sec= option comes at the middle or end of the list,
we take the initial export options as applying to that list of flavors,
and don't assume the first options were meant to apply to a default
(sec=sys) case.  So:

	ro,sec=krb5,rw

is the same as

	sec=krb5,ro,rw

is the same as

	sec=krb5,rw

and gets you an export accessible only with krb5.

and if you meant those first options to apply to sec=sys, that needs to
be explicitly stated:

	sec=sys,ro,sec=krb5,rw

I don't know if that's consistent with Solaris or not.

My guess is that if someone appends a "sec=krb5" option at the end of a
long list of options, then what we do is probably what they intended,
since previous to this, order didn't really matter to export options
(except in the odd case of conflicting options).  So I think it's less
suprising behavior in simple cases.  But it may make the behavior in
general more complicated to describe.

--b.

commit ccee90d1039b2ba81b497ac6374addc627887da3
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Jul 21 19:30:04 2009 -0400

    Don't give client an empty flavor list
    
    In the absence of an explicit sec= option on an export, rpc.mountd is
    returning a zero-length flavor list to clients in the MOUNT results.
    
    The linux client doesn't seem to mind, but the Solaris client
    (reasonably enough) is giving up; the symptom is a "security mode does
    not match" error on mount.
    
    We could modify the export-parsing code to ensure the secinfo array is
    nonzero.  But I think it's slightly simpler to handle this default case
    in the implementation of the MOUNT call.  This is more-or-less the same
    thing the kernel does when mountd passes it an export without any
    security flavors specified.
    
    Thanks to Tom Haynes for bug report and diagnosis.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index b59f939..888fd8c 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -359,6 +359,11 @@ static void set_authflavors(struct mountres3_ok *ok, nfs_export *exp)
 		flavors[i] = s->flav->fnum;
 		i++;
 	}
+	if (i == 0) {
+		/* default when there is no sec= option: */
+		i = 1;
+		flavors[0] = AUTH_UNIX;
+	}
 	ok->auth_flavors.auth_flavors_val = flavors;
 	ok->auth_flavors.auth_flavors_len = i;
 }
