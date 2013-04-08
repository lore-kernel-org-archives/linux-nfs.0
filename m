Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756941Ab3DHOIh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Apr 2013 10:08:37 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r38E8bEC019161
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 8 Apr 2013 10:08:37 -0400
Subject: Re: [PATCH 1/2] Avoid reverse resolution for server name
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <5162C8A5.4030307@RedHat.com>
References: <515B2F8D.3030302@RedHat.com>
	 <1364931149-18484-2-git-send-email-simo@redhat.com>
	 <5162C8A5.4030307@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 08 Apr 2013 10:08:36 -0400
Message-ID: <1365430116.20560.6.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-04-08 at 09:39 -0400, Steve Dickson wrote:
> 
> On 02/04/13 15:32, Simo Sorce wrote:
> > A NFS client should be able to work properly even if the DNS Reverse record
> > for the server is not set. There is no excuse to forcefully prevent that
> > from working when it can.
> > 
> > This patch adds a new pair of options (-z/-Z) that allow to turn on/off
> > DNS reverse resolution for determining the server name to use with GSSAPI.
> Again, please tell me why we need the -Z flag when that is the default?

The idea is to switch the default in the code at some point, so then -Z
will be needed to get back to the original behavior.

The idea is that by having both flags a distribution may choose to
decide now what behavior they want and use the relative flag. Then even
if we change the default their configuration will not "break".

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

