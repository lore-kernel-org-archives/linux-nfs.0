From: Ivan Shmakov <ivan-tPYS1JDixHzCyp4qypjU+w@public.gmane.org>
Subject: Re: IPv6 support
Date: Thu, 19 Nov 2009 22:18:31 +0600
Message-ID: <878we2bi94.fsf@violet.siamics.ipv6.uusia.org>
References: <4AEE9645.6010503@suse.de> <B3F6BEAE-A564-475F-93D5-7D6E0FC79147@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:52729 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752931AbZKSQSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Nov 2009 11:18:52 -0500
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1NB9ij-0002vM-KR
	for linux-nfs@vger.kernel.org; Thu, 19 Nov 2009 17:18:57 +0100
Received: from 81.201.254.124 ([81.201.254.124])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2009 17:18:57 +0100
Received: from ivan by 81.201.254.124 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2009 17:18:57 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "CL" == Chuck Lever <chuck.lever...> writes:

[...]

 CL> In other words, system support for IPv6 outside of NFS is kind of
 CL> like wireless was 5 years ago -- innumerable small admin tools that
 CL> users had to integrate themselves, usually without much success.

	BTW, I tend to disagree with that.  I've ``discovered'' IPv6
	only this summer, and for me, the whole thing was smooth...

	... Almost.  There were only a few issues:

	* /etc/network/interfaces (like in Debian GNU/Linux) handling is
	  a bit IPv4-centric (even more so in Etch, oldstable); say, one
	  may have to resort to the hacks like:

iface eth1 inet6 static
    address X:Y:Z:W::1234:5678
    netmask 64
    gateway X:Y:Z:W::1
    post-up ip -6 addr add G:H:I:J::DEAD:1/64 dev "$IFACE" && ip -6 addr add K:L:M:N::1337:CAFE/64 dev "$IFACE"

	  (with Etch, one'd have to add IPv6 management commands to the
	  existing IPv4 interfaces' stanzas.)

	* the stable version of Squid lacks IPv6 support completely;
	  Apache has it, but it lacks caching, which is a must for me;

	* there're no VoIP switches with IPv6 support in Debian; in
	  particular, Asterisk speaks no IPv6, while FreeSWITCH is not
	  in Debian; (there was an ITP); there's Linphone for an
	  IPv6-compatible user agent;

	* NFS.

	Otherwise, I use IPv6 on a daily basis, both at home and at
	work, and there seems to be no significant flaws, other than
	those few above.

	Occasionally, some hardware seems to behave strangely (e. g., I
	was unable to use IPv6 in one of classrooms here), and sometimes
	there're noticeable response times from hosts using old NICs,
	but hey, there're still a couple of 10 Mbit/s hubs in the darker
	corners of the network, and nobody seems to worry about it much.

-- 
FSF associate member #7257

