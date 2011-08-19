Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7098 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676Ab1HSWPI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 18:15:08 -0400
Subject: Re: Please support NSF squashing multiple groups
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <201108192206.p7JM6cwN005330@bari.maths.usyd.edu.au>
Date: Fri, 19 Aug 2011 18:15:05 -0400
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, neilb@suse.de
Message-Id: <24645503-5C52-4C77-A87E-07653D9FECFE@netapp.com>
References: <201108192206.p7JM6cwN005330@bari.maths.usyd.edu.au>
To: paul.szabo@sydney.edu.au
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 19, 2011, at 6:06 PM, paul.szabo@sydney.edu.au wrote:

> Dear Bruce,
> 
>>> Does that "work" also against the "evil remote root" e.g. when the
>>> remote machine is compromised?
>> 
>> ... Nothing you can do about that.
> 
> Thanks for the confirmation.
> 
>> ... if several people each have their own client ...
> 
> Not my situation.
> 
>>>> If you are using NFSv4 and kerberos than there already exist
>>>> interfaces to do what you want. See "man idmap.conf". ...
>>> 
>>> Sorry I do not use NFSv4 or kerberos, yet. ...
>> 
>> Look for "static" in a recent version of the idmapd.conf man page.
> 
> Thanks for the hint. Still, [Static] seems to translate UIDs only, seems
> to need umich_ldap and [UMICH_SCHEMA] for group memberships. Maybe
> idmapd ignores group membership lists as received from the client and
> sets the "local" list for each UID? - I guess I will need to investigate
> further how NFSv4 and idmapd work and try to implement them on my
> network.

Note that only AUTH_SYS sends GID and GID lists in the rpc_cred. RPCSEC_GSS with Kerberos only sends the krb5 principal to the server. The server looks up group membership via nsswitch - either /etc/groups, or ldap. Note ldap requires a secure communication usually with an X.509 certificate. NIS is not recommended for use with kerberos.

idmapd only deals with groups when a SETATTR arrives with ACE who's that are group names where it maps the groupname@domain to a gid, or a GETATTR ACL request where it maps gid->groupname@domain

-->Andy

> 
> Thanks, Paul
> 
> Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> School of Mathematics and Statistics   University of Sydney    Australia
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

