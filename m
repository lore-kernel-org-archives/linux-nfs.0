From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Is order for "exportfs -r" and rpc.mountd important?
Date: Thu, 04 Dec 2008 09:43:55 -0500
Message-ID: <4937ECAB.3020407@RedHat.com>
References: <200811281541.39272.t.bubeck@reinform.de> <200812041025.02563.t.bubeck@reinform.de> <4937E243.1080608@RedHat.com> <200812041516.14114.t.bubeck@reinform.de> <20081204143553.GC3495@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Dr. Tilmann Bubeck" <t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50025 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627AbYLDOqI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 09:46:08 -0500
In-Reply-To: <20081204143553.GC3495@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> On Thu, Dec 04, 2008 at 03:16:13PM +0100, Dr. Tilmann Bubeck wrote:
>> It's very good that it is fixed in Fedora (my preferred distribution), but it 
>> is still wrong in SuSe (verified) and probably more.
>>
>> A better way would be to fix NFS and its utilities itself instead of fixing 
>> the distribution. This means, that the way the kernel and nfs-utils interact 
>> should be made more robust (see my posting before).
> 
> The problem of exportfs ignoring the uuid, at least, should be easy
> enough to fix.
> 
> I'd start by looking for the relevant code in nfs-utils/utils/exportfs/
> that passes the export entry down to the kernel and figure out what
> mountd is doing that it's not.

FYI... I created a bz (https://bugzilla.linux-nfs.org/show_bug.cgi?id=171) to 
track this problem

steved.
