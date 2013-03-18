Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f50.google.com ([209.85.219.50]:61643 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484Ab3CRSqt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Mar 2013 14:46:49 -0400
Received: by mail-oa0-f50.google.com with SMTP id l20so5898748oag.23
        for <linux-nfs@vger.kernel.org>; Mon, 18 Mar 2013 11:46:48 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 18 Mar 2013 14:46:48 -0400
Message-ID: <CAPCnwUeMeQuZo1ygbXAB-KXJbv71wtTsTbaELcT=ombWVSG4mg@mail.gmail.com>
Subject: Excessive group membership causes permission denied
From: Norman Elton <normelton@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a fairly well documented bug that we've run against. When
using Active Directory as a KDC, users with a large number of group
memberships can overrun a UDP packet, causing Kerberos to fall back to
TCP. When a user logs into the system, they have a kerberos ticket,
but get a "permission denied" when accessing the NFS share. We've
reproduced this by taking a functioning user, adding tons of group
membership. The error message pops right up.

The traditional fix is to set NO_AUTH_DATA_REQUIRED on the NFS
server's machine account, as explained here:
http://theether.net/kb/100205.

While this seems to work, it's a bit of a dirty hack. Any thoughts on
a root-cause? We're happy to serve as a guinea pig if anyone can point
us in the right direction.

Thanks,

Norman
