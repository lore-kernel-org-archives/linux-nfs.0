From: Chuck Lever <chuck.lever@oracle.com>
Subject: splice read byte accounting
Date: Wed, 27 Jan 2010 17:22:09 -0500
Message-ID: <39A11474-A44E-49FE-8135-54B384254311@oracle.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:46019 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756213Ab0A0WXQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2010 17:23:16 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

nfs_file_splice_write() accounts for the bytes in the request in the  
"normal bytes written" counter, but nfs_file_splice_read() does not  
account for bytes read.

Should the read path count these as normal bytes as well, or should  
the write path not account for these bytes?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




