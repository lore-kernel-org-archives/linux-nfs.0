Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mxout12.cac.washington.edu ([140.142.33.31]:52896 "EHLO
	mxout12.cac.washington.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932130Ab0HJSUG convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Aug 2010 14:20:06 -0400
Received: from smtp.washington.edu (smtp.washington.edu [140.142.32.205] (may be forged))
	by mxout12.cac.washington.edu (8.14.3+UW09.11/8.14.3+UW09.11) with ESMTP id o7AIJeej020344
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 10 Aug 2010 11:19:40 -0700
Content-Type: text/plain; charset=us-ascii
Subject: Re: Tuning NFS client write pagecache
From: David Brodbeck <brodbd@u.washington.edu>
In-Reply-To: <AANLkTimeSG-WFONJsopxvOXwQmeeA5yoHMfOtdoHgmM7@mail.gmail.com>
Date: Tue, 10 Aug 2010 11:19:39 -0700
Message-Id: <2CCA2E8E-8606-48A1-91D2-3E91253E3004@u.washington.edu>
References: <4C5BFE47.8020905@mxtelecom.com> <20100806132620.GA2921@merit.edu> <AANLkTin_pg7GCw9jcB2JK+0TbGu+MrQEcv4H_qAg_A3H@mail.gmail.com> <1281116260.2900.6.camel@heimdal.trondhjem.org> <AANLkTimArNXgDSJeHrqsdAhCQo_O0=bhRuqsQEp0ofN7@mail.gmail.com> <1281123565.2900.17.camel@heimdal.trondhjem.org> <AANLkTin7Q_X6Ovy3Q2XYqWUbNd57XauGsDQGekU=DSf1@mail.gmail.com> <98DC3FB9-72A7-44CF-AB8B-914F2379B01B@oracle.com> <AANLkTimeSG-WFONJsopxvOXwQmeeA5yoHMfOtdoHgmM7@mail.gmail.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 10, 2010, at 10:52 AM, Peter Chacko wrote:
> And caching itself is not useful  for any streaming datapath.(Be it
> NFS cache,or memory cache or cpu cache or even a web cache).. backup
> is write-only operation, for all file objects...


It seems to me this is only true if you're talking strictly about full backups.  Any kind of incremental or differential backup is likely to do a significant amount of reading in order to determine what files need to be sent, unless it's storing data about each backup locally.  rsync, for example, needs to read from both filesystems to build up its file list.

-- 

David Brodbeck
System Administrator, Linguistics
University of Washington




