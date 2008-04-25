From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Fri, 25 Apr 2008 16:27:12 +0200
Message-ID: <20080425142712.GA6119@uio.no>
References: <20080423214929.GA24387@uio.no> <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com> <20080425080128.GA4848@uio.no> <09F49D76-049E-47A0-B0AD-5A177F8433E6@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:39596 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755098AbYDYO1P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 10:27:15 -0400
In-Reply-To: <09F49D76-049E-47A0-B0AD-5A177F8433E6@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 25, 2008 at 10:19:54AM -0400, Chuck Lever wrote:
>> The other submitters have iptables blocking on the server, though, and it
>> doesn't work for them either (one is using NFSv3, the other NFSv4). Is
>> this really working for you?
> I can't say until you post a complete description of a specific test  
> case.

On the client:

  iptables -A OUTPUT -d 10.0.0.10 -p udp -j DROP
  mount -t nfs 10.0.0.10:/foo /bar

Substitute 10.0.0.10 with the server, of course.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
