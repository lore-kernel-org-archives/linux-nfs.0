From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount.nfs: Configuration file parser ignoring options
Date: Wed, 20 Jan 2010 15:07:23 -0500
Message-ID: <4B57627B.6060700@RedHat.com>
References: <4B54D6E5.7030609@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751962Ab0ATUHZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jan 2010 15:07:25 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o0KK7ORX011341
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 20 Jan 2010 15:07:25 -0500
Received: from badhat.bos.devel.redhat.com (vpn-233-34.phx2.redhat.com [10.3.233.34])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o0KK7NlZ017842
	for <linux-nfs@vger.kernel.org>; Wed, 20 Jan 2010 15:07:24 -0500
In-Reply-To: <4B54D6E5.7030609-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/18/2010 04:47 PM, Steve Dickson wrote:
>     mount.nfs: Configuration file parser ignoring options
> 
>     When the protocol version is set on the command line,
>     none of the variables set in the configuration file
>     are passed down to the kernel due to a bug in the 
>     parsing routine. 
> 
> Tested-by: Jeff Layton <jlayton@redhat.com>
Committed...

steved.
