Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36570 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756622Ab1HTAT4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 20:19:56 -0400
Date: Sat, 20 Aug 2011 10:19:46 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: paul.szabo@sydney.edu.au, andros@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: Please support NSF squashing multiple groups
Message-ID: <20110820101946.45ffab49@notabene.brown>
In-Reply-To: <20110819234534.GC3589@fieldses.org>
References: <24645503-5C52-4C77-A87E-07653D9FECFE@netapp.com>
	<201108192235.p7JMZhqt006283@bari.maths.usyd.edu.au>
	<20110819234534.GC3589@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 19 Aug 2011 19:45:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Sat, Aug 20, 2011 at 08:35:43AM +1000, paul.szabo@sydney.edu.au wrote:
> > Dear Andy,
> > 
> > > Note that only AUTH_SYS sends GID and GID lists in the rpc_cred.
> > > RPCSEC_GSS with Kerberos only sends the krb5 principal to the server.
> > > The server looks up group membership via nsswitch - either /etc/groups
> > > ...
> > 
> > Can the server be set so as to ignore any AUTH_SYS sends, and accept
> > RPCSEC_GSS only?
> 
> Add something like sec=krb5:krb5i:krb5p to all your exports.
> 
> > > idmapd only deals with groups when a SETATTR arrives with ACE who's that
> > > are group names where it maps the groupname@domain to a gid, or a
> > > GETATTR ACL request where it maps gid->groupname@domain
> > 
> > Can the server be set so as to ignore any attempts from the client to
> > set group memberships, but always set its own from /etc/group?
> 
> Use kerberos, or run mountd with the --manage-gids option.
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

I almost suggested this, but then realised that it doesn't help.

With AUTH_SYS the client sends a UID, a GID and a list of at most 16
auxiliary GIDs.

With --manage-gids, the server ignores the list of auxiliary GIDs and
generates a list locally based on the UID.
So the UID and primary GID from the server are still trusted.

So kerberos is really the only option to be able to filter uids and gids
under user-space control.

When I suggested looking at idmap I was actually imagining writing your own
plug-in that did whatever mapping and filtering you wanted.

I think I mentioned before that you would need to use kerberos and NFSv4 to
make use of this but in fact you just need kerberos.  It will work with
NFSv3, though with some limitations.
In particular:
  when the client issues a chown/chgrp request, the uid/gid is used directly
  - idmap does not have a chance to filter/translate it (in v4 it does).
  When the client issues a getattr, the uid/gid are passed through
  unchanged.  idmap does not get to translate it (in v4 it does).

The only mapping available with v3 is the authenticated username of the
entity which issued the request.  idmap gets to translate that into a uid and
gids however the plug-in tells it too.

NeilBrown


> 
> --b.

