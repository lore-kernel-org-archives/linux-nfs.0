Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404Ab2CHPLZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 10:11:25 -0500
Message-ID: <4F58CC1E.4030805@RedHat.com>
Date: Thu, 08 Mar 2012 10:11:26 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] exportfs: Stop racing exportfs on clusters
References: <1331150190-18401-1-git-send-email-steved@redhat.com> <20120307203649.GA582@fieldses.org> <20120307205005.GB582@fieldses.org> <AAB0D4F3-A275-482E-A520-06715885B08F@oracle.com>
In-Reply-To: <AAB0D4F3-A275-482E-A520-06715885B08F@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/07/2012 03:52 PM, Chuck Lever wrote:
> 
> On Mar 7, 2012, at 3:50 PM, J. Bruce Fields wrote:
> 
>> On Wed, Mar 07, 2012 at 03:36:49PM -0500, bfields wrote:
>>> On Wed, Mar 07, 2012 at 02:56:30PM -0500, Steve Dickson wrote:
>>>> This problem can occur when multiple cluster services fail over
>>>> at the same time, causing missing high-available exports.
>>>> Having a lot of nfs-exports will trigger this issue easier.
>>>
>>> Isn't the locking in support/export/xtab.c supposed to take care of
>>> this?
>>
>> Huh, maybe that's just meant to prevent etab from getting corrupted, or
>> mountd from seeing a partially-written file.
>>
>> But it probably doesn't prevent two exportfs processes from both reading
>> etab, adding an export, and each writing out an etab with its one export
>> added, with the last writer winning.
>>
>> Was that the problem?
> 
> For bug 224, yes.  After disparate concurrent exportfs commands race, the etab file ends up missing some exports.
This morning I took another look at this and there does indeed need to
be some global lock to stop to serialize dueling exportfs commands. The
locks in xtab.c are just to granular....

steved.
