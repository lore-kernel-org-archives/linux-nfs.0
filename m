From: Jeff Layton <jlayton@redhat.com>
Subject: possible module refcount leak with auth_gss
Date: Mon, 8 Dec 2008 10:28:55 -0500
Message-ID: <20081208102855.30081708@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55072 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750768AbYLHP3C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2008 10:29:02 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We had someone report a bug against Fedora that they were seeing very
high module reference counts for some krb5 related modules on his nfs
server. For instance:

# lsmod
Module                  Size  Used by
des_generic            25216  52736 
cbc                    12160  52736 
rpcsec_gss_krb5        15632  26370 

...the cbc and des_generic each have roughly 2 module references per
rpcsec_gss_krb5 refcount so I'm assuming that the "lynchpin" here is
the rpcsec_gss_krb5 refcount which seems to be increasing w/o bound.

I've been able to reproduce this fairly easily by setting up a nfs
server with a krb5 authenticated export. If I then mount that and
immediately unmount it from a client, the refcount on rpcsec_gss_krb5 on
the server increases by 1. For instance:

First mount and unmount:
Module                  Size  Used by
cbc                    12288  2 
rpcsec_gss_krb5        19208  1 
des_generic            25344  2 

Second mount and unmount:
Module                  Size  Used by
cbc                    12288  4 
rpcsec_gss_krb5        19208  2 
des_generic            25344  4 

Third mount and unmount:
Module                  Size  Used by
cbc                    12288  6 
rpcsec_gss_krb5        19208  3 
des_generic            25344  6 

...while that's an easy way to reproduce it, there may be other ways to
make it grow.

Some printk debugging shows that the references are increased as a
result of rsc_parse(). From my (rather naive) look at this code, it
looks like each entry in the rsc_cache holds a module reference.

I'm guessing that when these cache entries are released that the module
references also get released, but I haven't been successful in making
that occur. It seems like the module references are never put, so either
the entries are never getting flushed out of the cache or the module
references aren't being properly released by this code. There's no
"content" file for this cache though, so it's hard to tell whether the
cache is populated at any given time.

Either way, this seems likely to be a bug. There doesn't seem to be a
way to make the refcounts go down again once they've been increased. Can
anyone confirm whether this is working as intended? If not, do you have
any idea where the problem may be, or how to approach tracking this
down? Unfortunately, I'm finding this code to be very hard to follow.

Any help or suggestions appreciated...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
