Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61015 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756752Ab3BWOuA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Feb 2013 09:50:00 -0500
Message-ID: <5128D714.4020000@RedHat.com>
Date: Sat, 23 Feb 2013 09:49:56 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSDv4.2: Added NFS v4.2 support to the NFS server
References: <1361552981-29385-1-git-send-email-steved@redhat.com> <1361552981-29385-3-git-send-email-steved@redhat.com> <20130222180515.GA30856@fieldses.org> <20130222181018.GC10846@pad.fieldses.org>
In-Reply-To: <20130222181018.GC10846@pad.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 22/02/13 13:10, J. Bruce Fields wrote:
> On Fri, Feb 22, 2013 at 01:05:15PM -0500, J. Bruce Fields wrote:
>> On Fri, Feb 22, 2013 at 12:09:41PM -0500, Steve Dickson wrote:
>>> This enable NFSv4.2 support for the server. To enable this
>>> code do the following:
>>>   echo "+4.2" >/proc/fs/nfsd/versions
>>
>> Give it a config option and we're set....
> 
> Also, while you're testing these: worth firing up wireshark and checking
> that "2"'s actually being sent in minorversion field, both on ordinary
> compounds and on callbacks.
I just confirmed with these latest bits, minorversion is definitely getting
set to "2".

steved.
  
