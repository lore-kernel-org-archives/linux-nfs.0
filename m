From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] nfs-utils: nfs-iostat.py autofs cleanup and option
 to sort by ops/s
Date: Tue, 15 Sep 2009 14:49:14 -0400
Message-ID: <4AAFE1AA.4050007@RedHat.com>
References: <4AAF1EBA.4090207@dreamworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Lans Carstensen <Lans.Carstensen-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758256AbZIOStj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2009 14:49:39 -0400
In-Reply-To: <4AAF1EBA.4090207-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/15/2009 12:57 AM, Lans Carstensen wrote:
> Here's the testest/reworked patchset for nfs-iostat.py, separating out:
> * python path change for package dependency detection and LSB compliance
> * Updating list of mount points each interval for autofs environments
> * Introduce optparse and update usage/help to use it
> * Adding --sort and --list=n options
> 
> Thanks in advance for reviewing this.
> 
Committed..

steved.
