Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from talus.maths.usyd.edu.au ([129.78.68.1]:33674 "EHLO
	talus.maths.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755515Ab1HSWGu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 18:06:50 -0400
Date: Sat, 20 Aug 2011 08:06:38 +1000
From: paul.szabo@sydney.edu.au
Message-Id: <201108192206.p7JM6cwN005330@bari.maths.usyd.edu.au>
To: bfields@fieldses.org
Subject: Re: Please support NSF squashing multiple groups
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
In-Reply-To: <20110819191945.GA1641@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dear Bruce,

>> Does that "work" also against the "evil remote root" e.g. when the
>> remote machine is compromised?
>
> ... Nothing you can do about that.

Thanks for the confirmation.

> ... if several people each have their own client ...

Not my situation.

>>> If you are using NFSv4 and kerberos than there already exist
>>> interfaces to do what you want. See "man idmap.conf". ...
>> 
>> Sorry I do not use NFSv4 or kerberos, yet. ...
>
> Look for "static" in a recent version of the idmapd.conf man page.

Thanks for the hint. Still, [Static] seems to translate UIDs only, seems
to need umich_ldap and [UMICH_SCHEMA] for group memberships. Maybe
idmapd ignores group membership lists as received from the client and
sets the "local" list for each UID? - I guess I will need to investigate
further how NFSv4 and idmapd work and try to implement them on my
network.

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia
