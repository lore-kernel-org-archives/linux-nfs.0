Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7260 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753069Ab1HVOXX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2011 10:23:23 -0400
Subject: Re: Please support NSF squashing multiple groups
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <201108192235.p7JMZhqt006283@bari.maths.usyd.edu.au>
Date: Mon, 22 Aug 2011 10:23:19 -0400
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, neilb@suse.de
Message-Id: <448D50C6-5CD6-4630-B9A2-D9A5A769CCCE@netapp.com>
References: <201108192235.p7JMZhqt006283@bari.maths.usyd.edu.au>
To: paul.szabo@sydney.edu.au
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 19, 2011, at 6:35 PM, paul.szabo@sydney.edu.au wrote:

> Dear Andy,
> 
>> Note that only AUTH_SYS sends GID and GID lists in the rpc_cred.
>> RPCSEC_GSS with Kerberos only sends the krb5 principal to the server.
>> The server looks up group membership via nsswitch - either /etc/groups
>> ...
> 
> Can the server be set so as to ignore any AUTH_SYS sends, and accept
> RPCSEC_GSS only?

For now, yes. Use sec=krb5 and/or krb5i,krb5p export options without sec=sys.
> 
>> idmapd only deals with groups when a SETATTR arrives with ACE who's that
>> are group names where it maps the groupname@domain to a gid, or a
>> GETATTR ACL request where it maps gid->groupname@domain
> 
> Can the server be set so as to ignore any attempts from the client to
> set group memberships, but always set its own from /etc/group?

This is the only behavior the Linux server currently has with Kerberos - it always queries it's local view of group membership.

Note that if the Windows Active Directory is used as a Kerberos KDC, it adds an authorization payload to the Kerberos ticket (a PAC) which contains a user's group memberships.  There is an effort to add a similar payload to MIT KDC. The Linux server will eventually be able to use this information to avoid a local call to obtain group memberships.

-->Andy

> 
> Thanks, Paul
> 
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia

