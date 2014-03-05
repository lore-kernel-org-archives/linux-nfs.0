Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:49690 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbaCEULy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2014 15:11:54 -0500
Date: Wed, 5 Mar 2014 15:11:49 -0500
From: Jim Rees <rees@umich.edu>
To: Andrew Martin <amartin@xes-inc.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140305201149.GA16212@umich.edu>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
 <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I prefer hard,intr which lets you interrupt the hung process.
