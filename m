From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Exposing cache statistics
Date: Wed, 15 Apr 2009 13:30:05 -0700
Message-ID: <49E643CD.9070809@disney.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:30044 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755614AbZDOUaH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2009 16:30:07 -0400
Received: from ling.fas.fa.disney.com (ling.fas.fa.disney.com [172.30.192.99])
	by mailhub.fa.disney.com (Postfix) with ESMTP id 5CE461253BE
	for <linux-nfs@vger.kernel.org>; Wed, 15 Apr 2009 13:30:06 -0700 (PDT)
Received: from [172.30.160.30] (chaos.fas.fa.disney.com [172.30.160.30])
	by ling.fas.fa.disney.com (Postfix) with ESMTP id 23DA9E0BF9
	for <linux-nfs@vger.kernel.org>; Wed, 15 Apr 2009 13:30:06 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Has there been any effort to expose caching statistics to the end user? 
  On the client-side, it would be useful to see how much data is being 
re-used from cache vs data that gets retrieved over the wire.  Similarly 
on the server side, it would be nice to see how much data is being 
served from cache vs having to pull the data from disk.

Just wondering if anyone started anything to expose this sort of 
information.

Thanks
-kevin
