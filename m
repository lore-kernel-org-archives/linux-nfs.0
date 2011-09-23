Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753951Ab1IWNIN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 09:08:13 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8ND8DNb024305
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 09:08:13 -0400
Message-ID: <4E7C84BB.3070600@RedHat.com>
Date: Fri, 23 Sep 2011 09:08:11 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] configure.ac: clean up.
References: <1316720699-2611-1-git-send-email-steved@redhat.com>
In-Reply-To: <1316720699-2611-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/22/2011 03:44 PM, Steve Dickson wrote:
> Steve Dickson (3):
>   configure.ac: Remove the NFS v3 enable flag
>   configure.ac: Removed unused defines in config.h
>   configure.ac: Added a v4.1 dependency on v4.0
> 
>  configure.ac |   17 +++--------------
>  1 files changed, 3 insertions(+), 14 deletions(-)
> 
All three committed... 

steved.
