From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] statd: Teach nfs_compare_sockaddr() to handle NULL arguments.
Date: Mon, 25 Jan 2010 13:10:51 -0500
Message-ID: <4B5DDEAB.3020906@RedHat.com>
References: <4B5DCDEB.60708@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750768Ab0AYSKw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 13:10:52 -0500
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o0PIAqHU004342
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 13:10:52 -0500
Received: from badhat.bos.devel.redhat.com (vpn-234-7.phx2.redhat.com [10.3.234.7])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o0PIApDb023896
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 13:10:51 -0500
In-Reply-To: <4B5DCDEB.60708-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/25/2010 11:59 AM, Steve Dickson wrote:
> It seems the list of interfaces returned by getifaddrs()
> can contain a null address pointer (ifa->ifa_addr) even though 
> the interface is marked UP (this happens with the tun0 interface).
> 
> So this patch makes nfs_compare_sockaddr() return false
> if either one of its arguments is null..
> 
Committed...

steved.
