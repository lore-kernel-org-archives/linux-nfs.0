Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56056 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163Ab1HSXpi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 19:45:38 -0400
Date: Fri, 19 Aug 2011 19:45:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: paul.szabo@sydney.edu.au
Cc: andros@netapp.com, linux-nfs@vger.kernel.org, neilb@suse.de
Subject: Re: Please support NSF squashing multiple groups
Message-ID: <20110819234534.GC3589@fieldses.org>
References: <24645503-5C52-4C77-A87E-07653D9FECFE@netapp.com>
 <201108192235.p7JMZhqt006283@bari.maths.usyd.edu.au>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201108192235.p7JMZhqt006283@bari.maths.usyd.edu.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 20, 2011 at 08:35:43AM +1000, paul.szabo@sydney.edu.au wrote:
> Dear Andy,
> 
> > Note that only AUTH_SYS sends GID and GID lists in the rpc_cred.
> > RPCSEC_GSS with Kerberos only sends the krb5 principal to the server.
> > The server looks up group membership via nsswitch - either /etc/groups
> > ...
> 
> Can the server be set so as to ignore any AUTH_SYS sends, and accept
> RPCSEC_GSS only?

Add something like sec=krb5:krb5i:krb5p to all your exports.

> > idmapd only deals with groups when a SETATTR arrives with ACE who's that
> > are group names where it maps the groupname@domain to a gid, or a
> > GETATTR ACL request where it maps gid->groupname@domain
> 
> Can the server be set so as to ignore any attempts from the client to
> set group memberships, but always set its own from /etc/group?

Use kerberos, or run mountd with the --manage-gids option.

--b.
