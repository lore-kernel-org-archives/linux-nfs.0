Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47019 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003Ab1FOFe7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2011 01:34:59 -0400
Received: by bwz15 with SMTP id 15so180523bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 22:34:58 -0700 (PDT)
Message-ID: <4DF8447C.40409@gmail.com>
Date: Wed, 15 Jun 2011 11:04:52 +0530
From: Amit Tewari | gmail <tewari.a@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: FSCache and NFS Attribute caching
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
fscache is being considered to be deployed with NFS 3 server in a 
metadata rich environment (millions of small files, with very low rate 
of file data change). At present actimeo=600 is used with NFS mount 
options (without fscache), to cache file attributes. I am not clear on

1. How FSCache handles meta data caching?
2. Does FSCache consider actimeo values before making a request to server?
3. When FSCache has to do metadata lookup from server, does it check 
local cache first and then server lookup is performed?

need some definitive answer. Nearest that i could find anything is:
http://kerneltrap.org/Linux/Local_Caching_For_Network_Filesystems
http://linux-nfs.org/pipermail/nfsv4/2006-August/004844.html (for NFS v4)
http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/Storage_Administration_Guide/fscachelimitnfs.html

Ultimate goal is to reduce metadata lookup load from the NFS server. Any 
clarity/ pointers/ help will be highly appreciated.

Thanks in advance.

Regards
Amit
