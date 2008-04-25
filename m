From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Sat, 26 Apr 2008 01:57:13 +0200
Message-ID: <20080425235713.GA9109@uio.no>
References: <20080423214929.GA24387@uio.no> <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com> <20080425080128.GA4848@uio.no> <09F49D76-049E-47A0-B0AD-5A177F8433E6@oracle.com> <20080425142712.GA6119@uio.no> <4D5FA350-EED5-4204-8D70-E3BE5E400595@oracle.com> <20080425235546.GA9053@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:56907 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547AbYDYX5P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 19:57:15 -0400
In-Reply-To: <20080425235546.GA9053-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 26, 2008 at 01:55:46AM +0200, Steinar H. Gunderson wrote:
> I checked the original bug report, and indeed it seems that the blocking was
> on the client there as well. I'll ask the user to check what happens when the
> filtering is done server-side instead.

Hm, no, there's also reports of blocking on a firewall in the middle; see

  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=473171

/* Steinar */
-- 
Homepage: http://www.sesse.net/
