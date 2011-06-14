Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from col0-omc3-s5.col0.hotmail.com ([65.55.34.143]:23716 "EHLO
	col0-omc3-s5.col0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751145Ab1FNTED convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2011 15:04:03 -0400
Message-ID: <col107-w53E4D4DE3E93CFCFED9C62CA680@phx.gbl>
From: Brian Rossa <rossabri@hotmail.com>
To: <linux-nfs@vger.kernel.org>
Subject: Kerberos + LDAP + NFSv4 on Ubuntu Natty - Unable to recover
 unattended client
Date: Tue, 14 Jun 2011 18:58:30 +0000
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi all,

I've filed a bug report on Launchpad that addresses a reliably hung NFSv4 client that's authenticating with sec=krb5. It seems unlikely that this issue is indicative of an NFS bug, but I thought I might appeal to you guys for some insight. Anything you can offer would be very much appreciated. My bug report is here: https://bugs.launchpad.net/ubuntu/+bug/794112

As I mention in the report, the outstanding evidence from the syslog is an awful lot of "Error: state manager encountered RPCSEC_GSS session expired against NFSv4 server 192.168.0.2." The mailing list archives would seem to indicate that this is simply due to Kerberos ticket expiration, though I have trouble imagining that the nfs/krb5 toolchain would fail so catastrophically under such common circumstances. I suspect misconfiguration, though I'm too much of a n00b to identify any problem areas in my setup.

Again, anything you can offer would be very much appreciated.

Cheers!~Brian 		 	   		  