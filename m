Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:61559 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873Ab2HXAfS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Aug 2012 20:35:18 -0400
Date: Thu, 23 Aug 2012 20:25:36 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org,
        Norbert Aschendorff <norbert.aschendorff@yahoo.de>
Message-ID: <900847353.1046192.1345767936102.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <20120823144605.GA6923@fieldses.org>
Subject: Re: NFSv4, Name (string) mapping vs. raw UID, idmapd and Kernels >=
 3.3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> Adding Rick to the cc:
> 
> On Thu, Aug 23, 2012 at 11:21:29AM +0200, Norbert Aschendorff wrote:
> > I recently opened a thread on freebsd-stable about problems with the
> > mapping of UIDs to user strings (user@domain form) in NFSv4 packets
> > running newer kernels:
> > [http://www.mail-archive.com/freebsd-stable@freebsd.org/index.html#122549]
> > In
> > [http://www.mail-archive.com/freebsd-stable@freebsd.org/msg122571.html],
> > Rick says that the described issue may be related to the
> > NFSv4/NFSv4.1
> > RFCs which deny/allow sending "raw" numeric UIDs (1000 instead of
> > "user@domain").
> > The problem is that Linux kernels newer than 3.2 (the last working
> > kernel, on both Debian and Fedora; I've tested 3.3, 3.4 and 3.5)
> > send
> > these numeric UIDs/GIDs [1] which, as it's described in the
> > mentioned
> > email, may be convenient when mounting NFSv4 filesystems as root
> > filesystem (at a point where an idmapd/nfsuserd (on FreeBSD) isn't
> > already running) and numeric UIDs/GIDs are required (because of the
> > early stage)
> > Now it could be that Kernels newer than 3.2 (>= 3.3) support this
> > feature (which is said to appear in NFSv4.1) already - and FreeBSD
> > 9.0
> > does not (it shows 32767 as UID - due to that I discovered this
> > issue; a
> > Fedora 17/k3.5 system supports the numeric UIDs/GIDs without any
> > problems).
> 
> Yes, newer linux servers by default do return numeric ID's (unless
> kerberos is used).
> 
> > --> 1. Is this assumption correct? Or is it a bug as filed here:
> > [https://bugzilla.novell.com/show_bug.cgi?id=756897]
> 
> That's slightly different, as it concerns a *client* sending numeric
> id's to a server. The client should in that case be falling back on
> the
> old behavior, and if that's not working there's some other bug.
> 
> > --> 2. As Rick says finally in
> > [http://www.mail-archive.com/freebsd-stable@freebsd.org/msg122572.html],
> > it would be cool if this behavior was tunable. Is it tunable via
> > options
> > in /etc/exports? Or in idmapd.conf? (The man pages don't describe
> > such
> > directives (at least at the first look)).
> 
> It's tunable via the nfsd module's "nfs4_disable_idmapping" parameter.
> So, for example,
> 
> echo "N" > /sys/module/nfsd/parameters/nfs4_disable_idmapping
> 
> should return the server to its old behavior.
> 
> "Y" was made the default because even the old rfc 3530 language
> allowed
> servers to return numeric ID's, so we assumed correct clients would
> need
> to be prepared for them.
> 
Well, way back when, I did have support for the numeric uid/gid strings
and I disabled that code because I thought (based on some discussion in
the working group), that it wasn't supposed to be allowed.

Reading RFC3530, I see that it is typically ambiguous, although it
seems to say that numeric uid/gids should only be allowed when no
name<->uid/gid# exists. Here's a couple of snippets from RFC3530 around
page 47:

   provides additional rationale.  It is expected that the client and
   server will have their own local representation of owner and
   owner_group that is used for local storage or presentation to the end
   user.  
   >> Therefore, it is expected that when these attributes are
   transferred between the client and server that the local
   representation is translated to a syntax of the form
   "user@dns_domain".  This will allow for a client and server that do
   not use the same local representation the ability to translate to a
   common syntax that can be interpreted by both.

The ">>" sentence seems to lean towards using the user@domain form whenever possible?

Then on the next page:

   To provide a greater degree of compatibility with previous versions
   of NFS (i.e., v2 and v3), which identified users and groups by 32-bit
   unsigned uid's and gid's, owner and group strings that consist of
   decimal numeric values with no leading zeros can be given a special
   interpretation by clients and servers which choose to provide such
   support.  
   ** The receiver may treat such a user or group string as
   representing the same user as would be represented by a v2/v3 uid or
   gid having the corresponding numeric value.  A server is not
   obligated to accept such a string, but may return an NFS4ERR_BADOWNER
   instead.  
   --> To avoid this mechanism being used to subvert user and
   group translation, so that a client might pass all of the owners and
   groups in numeric form, a server SHOULD return an NFS4ERR_BADOWNER
   error when there is a valid translation for the user or owner
   designated in this way.  In that case, the client must use the
   appropriate name@domain string and not the special form for
   compatibility.

The sentence at "**" says a receiver "may" recognize the numeric uid/gid#
string. This would suggest that a client isn't expected/required to do so,
as I read it. (This page seems to be very confusing w.r.t. what clients/servers
are expected/required to support.)
The sentence at "-->" is a SHOULD (not a MUST, I admit) that seems to
say a server should only allow numeric uid/gid# strings when there isn't
a name<->uid/gid# translation and should avoid allowing clients to just
use uid/gid# strings?

Anyhow, I do plan to re-enable support for numeric uid/gid# strings in
the FreeBSD NFSv4 client, but it won't be released until 9.2 at the
earliest. (I, personally, have no problem with numeric uid/gid# strings.
I disabled support for them because I had thought the working group
didn't want them supported.)

> It may be the server-side default was too aggressive and needs to be
> changed, but we'd also like to make sure that clients are fixed.
> 

I have no strong opinion on this. I am glad to see that there is a way
to switch the server to use user@dns_domain so that it will work with
the currently released FreeBSD NFSv4.0 client.

rick
> --b.
