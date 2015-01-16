Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:52646 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261AbbAPJG4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2015 04:06:56 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1YC2rl-0004CU-5b
	for linux-nfs@vger.kernel.org; Fri, 16 Jan 2015 10:06:53 +0100
Received: from server.vandervlis.nl ([82.95.148.152])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 16 Jan 2015 10:06:53 +0100
Received: from paul by server.vandervlis.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 16 Jan 2015 10:06:53 +0100
To: linux-nfs@vger.kernel.org
From: Paul van der Vlis <paul@vandervlis.nl>
Subject: Re: Secure NFSv4 mounts and daemons
Date: Fri, 16 Jan 2015 10:06:45 +0100
Message-ID: <m9akb5$ig3$1@ger.gmane.org>
References: <54B6F7C1.5040208@zoho.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <54B6F7C1.5040208@zoho.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ralph,

Op 15-01-15 om 00:12 schreef Ralph Zack:
> Hi all,
> 
> I have a number of NFSv4 shares which should only be accessible after
> successful authentication, for which reason they are exported with
> sec=krb5p. However, this method requires the user to obtain a kerberos
> ticket to access files on the share, which is fine for regular users but
> causes issues for daemons which are not kerberos-aware.
> 
> What is the common way to handle this problem? It can hardly be the only
> solution to patch each service to obtain a ticket at startup. Please
> correct me if I'm wrong, but I could not find any mechanism besides
> kerberos that provides encryption and authentication for NFS shares. I'd
> be fine with authentication on a host level, I mainly want to ensure
> that only trusted machines can accesses these shares and that all
> traffic is encrypted. Without the overhead of establishing a VPN
> connection between client and server, in case anyone was going to
> suggest that ;)

I've once seen that something like this makes a ticket:
su -c "echo password | kinit user" user
But never used it in reality.

Maybe you can ask this question better in the Kerberos mailinglist.
I think this is not a good solution...

With regards,
Paul van der Vlis





-- 
Paul van der Vlis Linux systeembeheer, Groningen
http://www.vandervlis.nl/

