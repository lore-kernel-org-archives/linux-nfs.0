Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sender1.zohomail.com ([72.5.230.103]:38628 "EHLO
	sender1.zohomail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbbANXSt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 18:18:49 -0500
Message-ID: <54B6F7C1.5040208@zoho.com>
Date: Thu, 15 Jan 2015 00:12:01 +0100
From: Ralph Zack <ralphz@zoho.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Secure NFSv4 mounts and daemons
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I have a number of NFSv4 shares which should only be accessible after
successful authentication, for which reason they are exported with
sec=krb5p. However, this method requires the user to obtain a kerberos
ticket to access files on the share, which is fine for regular users but
causes issues for daemons which are not kerberos-aware.

What is the common way to handle this problem? It can hardly be the only
solution to patch each service to obtain a ticket at startup. Please
correct me if I'm wrong, but I could not find any mechanism besides
kerberos that provides encryption and authentication for NFS shares. I'd
be fine with authentication on a host level, I mainly want to ensure
that only trusted machines can accesses these shares and that all
traffic is encrypted. Without the overhead of establishing a VPN
connection between client and server, in case anyone was going to
suggest that ;)

Cheers,

Ralph

