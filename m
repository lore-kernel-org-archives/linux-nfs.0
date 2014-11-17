Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44276 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbaKQVbU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Nov 2014 16:31:20 -0500
Message-ID: <546A6925.30301@RedHat.com>
Date: Mon, 17 Nov 2014 16:31:17 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Henrique Martins <linux@martins.cc>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfsd/exportfs: allow empty exports file
References: <17903.1415988313@monster.martins.cc> <5469F395.9080701@RedHat.com> <29411.1416239616@monster.martins.cc> <546A47EA.9090707@RedHat.com> <505.1416256048@monster.martins.cc>
In-Reply-To: <505.1416256048@monster.martins.cc>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/17/2014 03:27 PM, Henrique Martins wrote:
>> Please take a look at what I committed today to
>> see it it works in your environment. We'll work
>> on it if it does not...
> 
> Committed to?
git://linux-nfs.org/nfs-utils

commit e725def62c73b4aa269fefc4c0d96abb41927fcb
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Nov 17 13:17:20 2014 -0500

    exportfs: Do not fail on empty exports file.
    
    Commit 076dd80 introduced a regression that causes
    exportfs to fail when there is an empty /etc/exports
    file. A empty /etc/exports file is valid and should
    not cause exportfs to fail.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

steved.
