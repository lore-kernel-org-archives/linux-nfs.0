From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: nfsstat --sleep=#
Date: Wed, 11 Mar 2009 18:37:08 -0700
Message-ID: <49B86744.6060105@disney.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:3295 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753474AbZCLBqf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 21:46:35 -0400
Received: from ling.fas.fa.disney.com (ling.fas.fa.disney.com [172.30.192.99])
	by mailhub.fa.disney.com (Postfix) with ESMTP id 9DAC01253BC
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 18:46:33 -0700 (PDT)
Received: from beaver.fas.fa.disney.com (beaver.fas.fa.disney.com [172.30.160.222])
	by ling.fas.fa.disney.com (Postfix) with ESMTP id 911C8E0979
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 18:46:33 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'd really like to have a way to output the nfsstat counters at regular 
intervals (every 3 seconds) where the output is the difference between 3 
seconds ago and now.  Frequently I'll run a test and want to watch the 
nfs call profile throughout the course of the test.

Does something like this already exist?
Are there objections to seeing a feature like this?

I'm thinking something like:
nfsstat --sleep=1

  nfs v3 call:   Server   Client
        total:        0     3476
         null:        0        0
      getattr:        0     1679
      setattr:        0        0
       lookup:        0      839
       access:        0      839
     readlink:        0        0
         read:        0        0
        write:        0        0
       create:        0        0
        mkdir:        0        0
      symlink:        0        0
        mknod:        0        0
       remove:        0        0
        rmdir:        0        0
       rename:        0        0
         link:        0        0
      readdir:        0        0
  readdirplus:        0        0
       fsstat:        0      119
       fsinfo:        0        0
     pathconf:        0        0
       commit:        0        0

