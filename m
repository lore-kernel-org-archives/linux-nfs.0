Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65509 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751254Ab1FRN1c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Jun 2011 09:27:32 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p5IDRWUQ013249
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 18 Jun 2011 09:27:32 -0400
Message-ID: <4DFCA7C2.8050604@RedHat.com>
Date: Sat, 18 Jun 2011 09:27:30 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils crossmnt bugfix, and cleanup
References: <1308063492-30103-1-git-send-email-bfields@redhat.com>
In-Reply-To: <1308063492-30103-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Bruce,

On 06/14/2011 10:58 AM, J. Bruce Fields wrote:
> We've long had a bug with crossmnt handling which could cause a parent's
> export options to override those of a child in some cases.
> 
> While I was there, I also did some cleanup, mainly of nfsd_fh().  It was
> long and complicated, now it's short and complicated.  We could probably
> simplify the logic with a little more work.
> 
> --b.
Which bug are you referring to?

steved. 
