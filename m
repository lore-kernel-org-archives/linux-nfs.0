Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:50749 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbaCFS07 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 13:26:59 -0500
Received: by mail-ie0-f172.google.com with SMTP id as1so3178810iec.17
        for <linux-nfs@vger.kernel.org>; Thu, 06 Mar 2014 10:26:59 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140306173632.GA18545@umich.edu>
Date: Thu, 6 Mar 2014 13:26:56 -0500
Cc: Andrew Martin <amartin@xes-inc.com>, bhawley@luminex.com,
        Brown Neil <neilb@suse.de>, linux-nfs-owner@vger.kernel.org,
        linux-nfs@vger.kernel.org
Message-Id: <C562DF8A-E652-4D94-A7FD-2546FF288166@primarydata.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <20140306145042.6db53f60@notabene.brown> <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com> <20140306163721.0edfb498@notabene.brown> <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry> <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com> <20140306162208.GA18207@umich.edu> <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com> <20140306173632.GA18545@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2014, at 12:36, Jim Rees <rees@umich.edu> wrote:

> Why would a bunch of blocked apaches cause high load and reboot?

Good question. Are the TCP reconnect attempts perhaps eating up all the reserved ports and leaving them in the TIME_WAIT state? ‘netstat -tn’ should list all the ports currently in use by TCP connections.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

