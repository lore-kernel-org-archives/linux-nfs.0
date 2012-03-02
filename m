Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e34.co.us.ibm.com ([32.97.110.152]:53602 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558Ab2CBT2Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 14:28:16 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 2 Mar 2012 12:28:16 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 913293E4004F
	for <linux-nfs@vger.kernel.org>; Fri,  2 Mar 2012 12:28:11 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q22JRxcq116208
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 12:28:00 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q22JRxHR019557
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 12:27:59 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q22JRxxY019545
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 12:27:59 -0700
Date: Fri, 2 Mar 2012 13:27:58 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
Message-ID: <20120302192758.GA28389@us.ibm.com>
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>
 <4F2BC1C0.8070900@panasas.com>
 <20120203231623.442fefde@notabene.brown>
 <20120203142945.GA31805@us.ibm.com>
 <4F2E620F.5090100@panasas.com>
 <20120207204401.GA31752@us.ibm.com>
 <4F511B21.1020907@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F511B21.1020907@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson [SteveD@redhat.com] wrote:
> Hello,
> 
> First of all my apologizes for dropping this... I saw Boaz's
> NACK and never got back to it.. More comments in-line. 

No need for them.

> Question, How does this patch stop the mtab from getting polluted with
> the device name with multiple "/"? 

It doesn't. Is that a problem? It only matches entries in /etc/mtab and
/proc/mounts correctly for unmount to work.

Regards, Malahal.

