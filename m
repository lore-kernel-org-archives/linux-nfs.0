Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932188Ab1ERAqx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 20:46:53 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <19923.5877.159088.341353@regina.usersys.redhat.com>
Date: Wed, 18 May 2011 10:46:45 +1000
From: Max Matveev <makc@redhat.com>
To: James Pearson <james-p@moving-picture.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: How to control the order of different export options for different
 client formats?
In-Reply-To: <4DD2A084.1040905@moving-picture.com>
References: <4DD2A084.1040905@moving-picture.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 17 May 2011 17:21:24 +0100, James Pearson wrote:

 james-p> Is there any way to control the order in which clients are
 james-p> checked for export options?

 james-p> i.e. I would like netgroups to take precedence over subnets

You're out of luck here - the entires are checked in the following
order: FQDN, subnet, wildcard, netgroup, anonymous and finally gss.
Here 'wildcard' means anything except the bare '*' which is considered
anonymous.  Any entries on the same "level", i.e. two netgroups or two
FQDNs are checked in the same order in which they appear in
/etc/exports.

max
