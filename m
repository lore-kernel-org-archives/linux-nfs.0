Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39635 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466Ab2CMQWD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2012 12:22:03 -0400
Received: by eaaq12 with SMTP id q12so369019eaa.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Mar 2012 09:22:01 -0700 (PDT)
From: Anton Starikov <ant.starikov@gmail.com>
Content-Type: text/plain; charset=us-ascii
Subject: NFS4 without id mapper
Date: Tue, 13 Mar 2012 17:21:57 +0100
Message-Id: <66B6E4EA-A94C-4FD9-87C1-A110B0AB3D71@gmail.com>
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Apple Message framework v1257)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have probably stupid question, but is there a way to use NFS-4 in old-fashoned way without any idmapper involved? Assuming setup with auth=sys/none and no root squash.

Thanks, 

Anton.