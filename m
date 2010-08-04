Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mxout13.cac.washington.edu ([140.142.32.202]:50733 "EHLO
	mxout13.cac.washington.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759044Ab0HDVcq convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 17:32:46 -0400
Received: from smtp.washington.edu (smtp.washington.edu [140.142.33.34] (may be forged))
	by mxout13.cac.washington.edu (8.14.3+UW09.11/8.14.3+UW09.11) with ESMTP id o74LW7Wi023820
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 4 Aug 2010 14:32:07 -0700
Content-Type: text/plain; charset=us-ascii
Subject: Re: numeric UIDs
From: David Brodbeck <brodbd@u.washington.edu>
In-Reply-To: <C2AFF31B-A4A4-432C-A152-B28676B8C3A4@netapp.com>
Date: Wed, 4 Aug 2010 14:32:06 -0700
Message-Id: <03068BD0-0613-469E-B918-07019EC54055@u.washington.edu>
References: <201008030401.33552.dreck@vmsd.ath.cx> <20100803164318.GB13896@merit.edu> <20100803192216.GC31579@fieldses.org> <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com> <20100803215704.GA15494@merit.edu> <1280873719.14520.17.camel@heimdal.trondhjem.org> <20100803222337.GA9752@fieldses.org> <1280874675.14520.23.camel@heimdal.trondhjem.org> <20100803224245.GB9752@fieldses.org> <1280887336.24669.23.camel@heimdal.trondhjem.org> <0969EC03-E225-4265-BADC-582F2089D13E@u.washington.edu> <C2AFF31B-A4A4-432C-A152-B28676B8C3A4@netapp.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 4, 2010, at 11:30 AM, Andy Adamson wrote:

> 
> On Aug 4, 2010, at 1:06 PM, David Brodbeck wrote:
> 
>> 
>> On Aug 3, 2010, at 7:02 PM, Trond Myklebust wrote:
>> 
>>> On Tue, 2010-08-03 at 18:42 -0400, J. Bruce Fields wrote:
>>>> On Tue, Aug 03, 2010 at 06:31:15PM -0400, Trond Myklebust wrote:
>>>>> On Tue, 2010-08-03 at 18:23 -0400, J. Bruce Fields wrote:
>>>>>> On Tue, Aug 03, 2010 at 06:15:19PM -0400, Trond Myklebust wrote:
>>>> 
>>>>> 2) Why is AUTH_SYS so sacrosanct?
>>>> 
>>>> Because it's what almost everyone uses.
>>> 
>>> No. It's the _default_. ...and a really really bad default.
>> 
>> The problem is the only supported alternative is to set up Kerberos.  This is a lot of work, especially for established sites where it essentially requires every user to change their password during the migration.  It also creates problems with ticket expiration if you have daemons or batch jobs that need continuous access to NFS filesystems.
> 
> Changing passwords is a good thing - should be done on a regular basis anyway.

True, but getting all the users of an academic system -- some of whom may not be active in any given term -- to change their passwords by a particular flag day is not an easy task.  Doable, sure, but painful.

> Ticket expiration is handled by using a keytab and a cron job to refresh the keytab.

That feels like a hack, but it ought to be workable for daemons like apache.  A bigger problem is Condor batch jobs, which are user-submitted and may run for days or even weeks, potentially after sitting in a queue for several hours.  It's not clear to me how to make this work reliably in a Kerberos environment.  The Kerberos security model seems to implicitly assume that any file access will happen within a short period of time after an interactive login, and that isn't always the case for our site.

There also appear to be outstanding issues where one user's expired Kerberos ticket can cause NFS reads by other users to hang; e.g.:
https://bugzilla.redhat.com/show_bug.cgi?id=537193

-- 

David Brodbeck
System Administrator, Linguistics
University of Washington




