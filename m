Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:18684 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550Ab2AQUP1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jan 2012 15:15:27 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: [LSF/MM TOPIC] end-to-end data and metadata corruption detection
Date: Tue, 17 Jan 2012 15:15:23 -0500
Message-Id: <38C050B3-2AAD-4767-9A25-02C33627E427@oracle.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org
To: lsf-pc@lists.linux-foundation.org
Mime-Version: 1.0 (Apple Message framework v1251.1)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I know there is some work on ext4 regarding metadata corruption detection; btrfs also has some corruption detection facilities.  The IETF NFS working group is considering the addition of corruption detection to the next NFSv4 minor version.  T10 has introduced DIF/DIX.

I'm probably ignorant of the current state of implementation in Linux, but I'm interested in understanding common ground among local file systems, block storage, and network file systems.  Example questions include:  Do we need standardized APIs for block device corruption detection?  How much of T10 DIF/DIX should NFS support?  What are the drivers for this feature (broad use cases)?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




