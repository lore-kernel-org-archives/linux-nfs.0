Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mxout12.cac.washington.edu ([140.142.33.31]:58869 "EHLO
	mxout12.cac.washington.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751314Ab0HDSFp convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 14:05:45 -0400
Received: from smtp.washington.edu (smtp.washington.edu [140.142.32.205] (may be forged))
	by mxout12.cac.washington.edu (8.14.3+UW09.11/8.14.3+UW09.11) with ESMTP id o74Hskh2031809
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 4 Aug 2010 10:54:46 -0700
Subject: Re: numeric UIDs
Content-Type: text/plain; charset=us-ascii
From: David Brodbeck <brodbd@u.washington.edu>
In-Reply-To: <1280887336.24669.23.camel@heimdal.trondhjem.org>
Date: Wed, 4 Aug 2010 10:06:05 -0700
Message-Id: <0969EC03-E225-4265-BADC-582F2089D13E@u.washington.edu>
References: <201008030401.33552.dreck@vmsd.ath.cx> <20100803164318.GB13896@merit.edu> <20100803192216.GC31579@fieldses.org> <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com> <20100803215704.GA15494@merit.edu> <1280873719.14520.17.camel@heimdal.trondhjem.org> <20100803222337.GA9752@fieldses.org> <1280874675.14520.23.camel@heimdal.trondhjem.org> <20100803224245.GB9752@fieldses.org> <1280887336.24669.23.camel@heimdal.trondhjem.org>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 3, 2010, at 7:02 PM, Trond Myklebust wrote:

> On Tue, 2010-08-03 at 18:42 -0400, J. Bruce Fields wrote:
>> On Tue, Aug 03, 2010 at 06:31:15PM -0400, Trond Myklebust wrote:
>>> On Tue, 2010-08-03 at 18:23 -0400, J. Bruce Fields wrote:
>>>> On Tue, Aug 03, 2010 at 06:15:19PM -0400, Trond Myklebust wrote:
>> 
>>> 2) Why is AUTH_SYS so sacrosanct?
>> 
>> Because it's what almost everyone uses.
> 
> No. It's the _default_. ...and a really really bad default.

The problem is the only supported alternative is to set up Kerberos.  This is a lot of work, especially for established sites where it essentially requires every user to change their password during the migration.  It also creates problems with ticket expiration if you have daemons or batch jobs that need continuous access to NFS filesystems.

I've been looking at it for a while, because the 16-group limit is a problem for us, but it's a huge ball of wax.  I understand the security benefits, but the sheer complexity of setting it up and then coming up with workarounds for ticket expiration has me a bit cowed.

-- 

David Brodbeck
System Administrator, Linguistics
University of Washington




