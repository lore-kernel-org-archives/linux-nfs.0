Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from talus.maths.usyd.edu.au ([129.78.68.1]:53389 "EHLO
	talus.maths.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756375Ab1HSWgf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 18:36:35 -0400
Date: Sat, 20 Aug 2011 08:35:43 +1000
From: paul.szabo@sydney.edu.au
Message-Id: <201108192235.p7JMZhqt006283@bari.maths.usyd.edu.au>
To: andros@netapp.com
Subject: Re: Please support NSF squashing multiple groups
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, neilb@suse.de
In-Reply-To: <24645503-5C52-4C77-A87E-07653D9FECFE@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dear Andy,

> Note that only AUTH_SYS sends GID and GID lists in the rpc_cred.
> RPCSEC_GSS with Kerberos only sends the krb5 principal to the server.
> The server looks up group membership via nsswitch - either /etc/groups
> ...

Can the server be set so as to ignore any AUTH_SYS sends, and accept
RPCSEC_GSS only?

> idmapd only deals with groups when a SETATTR arrives with ACE who's that
> are group names where it maps the groupname@domain to a gid, or a
> GETATTR ACL request where it maps gid->groupname@domain

Can the server be set so as to ignore any attempts from the client to
set group memberships, but always set its own from /etc/group?

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia
